//
//  RSSChannelDetailsViewModel.swift
//  Feedy
//
//  Created by Danijel Huis on 19.05.2024..
//

import Foundation
import Combine
import Domain
import Localization

@MainActor public final class RSSChannelDetailsViewModel: SwiftUIViewModel {
    // Dependencies
    private let getRSSHistoryItemsUseCase: GetRSSHistoryItemsUseCase
    private let getRSSChannelUseCase: GetRSSChannelUseCase
    private let changeHistoryItemFavouriteStatusUseCase: ChangeHistoryItemFavouriteStatusUseCase
    private let updateLastReadItemIDUseCase: UpdateLastReadItemIDUseCase
    private let coordinator: Coordinator
    public let effectManager: SideEffectManager
    @Published public private(set) var state: State

    private var cancellables: Set<AnyCancellable> = []
    public init(rssHistoryItem: RSSHistoryItem, rssChannel: RSSChannel, getRSSHistoryItemsUseCase: GetRSSHistoryItemsUseCase, getRSSChannelUseCase: GetRSSChannelUseCase, changeHistoryItemFavouriteStatusUseCase: ChangeHistoryItemFavouriteStatusUseCase, updateLastReadItemIDUseCase: UpdateLastReadItemIDUseCase, effectManager: SideEffectManager, coordinator: Coordinator) {
        self.getRSSHistoryItemsUseCase = getRSSHistoryItemsUseCase
        self.getRSSChannelUseCase = getRSSChannelUseCase
        self.changeHistoryItemFavouriteStatusUseCase = changeHistoryItemFavouriteStatusUseCase
        self.updateLastReadItemIDUseCase = updateLastReadItemIDUseCase
        self.effectManager = effectManager
        self.coordinator = coordinator
        self.state = .init(rssHistoryItem: rssHistoryItem, rssChannel: rssChannel)
        observeEnvironment()
    }
    
    private func observeEnvironment() {
        // Observing for changes in favourite state
        getRSSHistoryItemsUseCase.output.sink { [weak self] event in
            guard let self else { return }
            // We can just update on every change, no need to check reason or item id.
            guard let historyItem = event.historyItems.first(where: { $0.id == self.state.rssHistoryItem.id }) else { return }
            self.state.rssHistoryItem = historyItem
        }.store(in: &cancellables)
    }
    
    public func send(_ action: Action) {
        switch action {
        case .onFirstAppear:
            loadRSSChannel(showLoading: true)
            
        case .didInitiateRefresh:
            loadRSSChannel(showLoading: false)
            
        case .toggleFavourites:
            let isFavourite = !self.state.rssHistoryItem.isFavourite
            try? self.changeHistoryItemFavouriteStatusUseCase.changeFavouriteStatus(historyItemID: self.state.rssHistoryItem.id, isFavourite: isFavourite)
                
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
            // Updagin last read item here
            self.updateLastReadItemID(historyItemID: self.state.rssHistoryItem.id, channel: self.state.rssChannel)
            self.state.isLoading = false
        }
    }
    
    private func updateLastReadItemID(historyItemID: UUID, channel: RSSChannel) {
        // First item is the most recent one (sorted in repository).
        if let lastItemID = channel.items.first?.guid {
            // No need to handle error, we could show alert but it wouldn't make sense for user.
            try? self.updateLastReadItemIDUseCase.updateLastReadItemID(historyItemID: historyItemID, lastItemID: lastItemID)
        }
    }
}

// MARK: - State & Action -

extension RSSChannelDetailsViewModel {
    public struct State: Equatable {
        // Data state
        var rssHistoryItem: RSSHistoryItem
        var rssChannel: RSSChannel
        var isLoading: Bool = true
        
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
