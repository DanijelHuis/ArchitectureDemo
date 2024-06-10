//
//  RSSChannelDetailsViewModel.swift
//  Feedy
//
//  Created by Danijel Huis on 19.05.2024..
//

import Foundation
import Combine
import Domain
import CommonUI

@MainActor public final class RSSChannelDetailsViewModel: SwiftUIViewModel {
    // Dependencies
    private let getRSSChannelsUseCase: GetRSSChannelsUseCase
    private let getRSSChannelUseCase: GetRSSChannelUseCase
    private let changeHistoryItemFavouriteStatusUseCase: ChangeHistoryItemFavouriteStatusUseCase
    private let coordinator: Coordinator
    public let effectManager: EffectManager
    @Published public private(set) var state: State

    private var cancellables: Set<AnyCancellable> = []
    public init(rssHistoryItem: RSSHistoryItem, rssChannel: RSSChannel, getRSSChannelsUseCase: GetRSSChannelsUseCase, getRSSChannelUseCase: GetRSSChannelUseCase, changeHistoryItemFavouriteStatusUseCase: ChangeHistoryItemFavouriteStatusUseCase, effectManager: EffectManager, coordinator: Coordinator) {
        self.getRSSChannelsUseCase = getRSSChannelsUseCase
        self.getRSSChannelUseCase = getRSSChannelUseCase
        self.changeHistoryItemFavouriteStatusUseCase = changeHistoryItemFavouriteStatusUseCase
        self.effectManager = effectManager
        self.coordinator = coordinator
        self.state = .init(rssHistoryItem: rssHistoryItem, rssChannel: rssChannel)
        observeEnvironment()
    }
    
    private func observeEnvironment() {
        // Observing for changes in favourite state
        getRSSChannelsUseCase.output.sink { [weak self] channels in
            guard let self else { return }
            // We can just update on every change, no need to check reason or item id.
            guard let channelResponse = channels.first(where: { $0.historyItem.id == self.state.rssHistoryItem.id }) else { return }
            self.state.rssHistoryItem = channelResponse.historyItem
        }.store(in: &cancellables)
    }
    
    public func send(_ action: Action) {
        switch action {
        case .onFirstAppear:
            loadRSSChannel(showLoading: true)
            
        case .didInitiateRefresh:
            loadRSSChannel(showLoading: false)
            
        case .toggleFavourites:
            self.effectManager.run {
                let isFavourite = !self.state.rssHistoryItem.isFavourite
                try? await self.changeHistoryItemFavouriteStatusUseCase.changeFavouriteStatus(historyItemID: self.state.rssHistoryItem.id, isFavourite: isFavourite)
            }
        case .didTapOnRSSItem(let link):
            guard let link else { return }
            coordinator.openRoute(.common(.safari(url: link)))
        }
    }
    
    private func loadRSSChannel(showLoading: Bool) {
        effectManager.run {
            if showLoading {
                self.state.isLoading = true
            }
            
            // Ignoring error intentionally, we already have channel loaded so if it fails just show old one.
            self.state.rssChannel = (try? await self.getRSSChannelUseCase.getRSSChannel(url: self.state.rssHistoryItem.channelURL)) ?? self.state.rssChannel
            self.state.isLoading = false
        }
    }
}

// MARK: - State & Action -

extension RSSChannelDetailsViewModel {
    public struct State: Equatable {
        // Data state
        var rssHistoryItem: RSSHistoryItem
        var rssChannel: RSSChannel
        var isLoading: Bool = false
        
        public init(rssHistoryItem: RSSHistoryItem, rssChannel: RSSChannel) {
            self.rssHistoryItem = rssHistoryItem
            self.rssChannel = rssChannel
        }
        
        // View state
        var title: String? { rssChannel.title }
        var isFavourite: Bool { rssHistoryItem.isFavourite }
        var items: [RSSChannelItemListCell.State] {
            rssChannel.items.map({ RSSChannelItemListCell.State(rssItem: $0) })
        }
        
        var status: ViewStatus {
            if isLoading {
                return .loading()
            } else if items.isEmpty {
                return .empty()
            } else {
                return .loaded(states: items)
            }
        }
    }
    
    public enum ViewStatus: Equatable {
        case empty(text: String = "rss_details_no_items".localized)
        case loading(text: String = "common_loading".localized)
        case loaded(states: [RSSChannelItemListCell.State])
    }
    
    public enum Action: Equatable {
        case onFirstAppear
        case didInitiateRefresh
        case toggleFavourites
        case didTapOnRSSItem(_ link: URL?)
    }
}
