//
//  RSSChannelListViewModel.swift
//  Feedy
//
//  Created by Danijel Huis on 18.05.2024..
//

import Foundation
import Combine
import Domain
import SwiftUI
import CommonUI

@MainActor public final class RSSChannelListViewModel: SwiftUIViewModel {
    // Dependencies
    private let getRSSHistoryItemsUseCase: GetRSSHistoryItemsUseCase
    private let removeRSSHistoryItemUseCase: RemoveRSSHistoryItemUseCase
    private let getRSSChannelsUseCase: GetRSSChannelsUseCase
    private let coordinator: Coordinator
    public let effectManager: SideEffectManager
    @Published public private(set) var state: State = State(historyItems: [], rssChannels: [:])
    // Private
    private var cancellables: Set<AnyCancellable> = []
    
    public init(getRSSHistoryItemsUseCase: GetRSSHistoryItemsUseCase, removeRSSHistoryItemUseCase: RemoveRSSHistoryItemUseCase, getRSSChannelsUseCase: GetRSSChannelsUseCase, effectManager: SideEffectManager, coordinator: Coordinator) {
        self.getRSSHistoryItemsUseCase = getRSSHistoryItemsUseCase
        self.removeRSSHistoryItemUseCase = removeRSSHistoryItemUseCase
        self.getRSSChannelsUseCase = getRSSChannelsUseCase
        self.coordinator = coordinator
        self.effectManager = effectManager
        observeEnvironment()
    }
    
    private func observeEnvironment() {
        getRSSHistoryItemsUseCase.output.sink { [weak self] event in
            guard let self else { return }
            state.historyItems = event.historyItems
            
            // We need to reload RSS channels only if they were updated or new one is added.
            switch event.reason {
            case .update, .add:
                reloadRSSChannels()
            case .remove, .favouriteStatusUpdated, .didUpdateLastReadItemID:
                break
            }
        }.store(in: &cancellables)
    }
    
    public func send(_ action: Action) {
        switch action {
        case .onFirstAppear, .didInitiateRefresh:
            getHistoryItems()
            
        case .didTapAddChannelButton:
            coordinator.openRoute(.rss(.add))
            
        case .didTapRemoveHistoryItem(let id):
            try? removeRSSHistoryItemUseCase.removeRSSHistoryItem(id)
            
        case .didSelectItem(let historyItemID):
            guard let historyItem = self.state.historyItems.first(where: { $0.id == historyItemID }) else { return }
            guard let channelResult = self.state.rssChannels[historyItemID] else { return }
            guard case let .success(channel) = channelResult else { return }
            coordinator.openRoute(.rss(.details(rssHistoryItem: historyItem, channel: channel)))
            
        case .toggleFavourites:
            state.isShowingFavourites.toggle()
        }
    }
    
    /// This will trigger getRSSHistoryItemsUseCase which will then reload and refresh.
    private func getHistoryItems() {
        do {
            try self.getRSSHistoryItemsUseCase.getRSSHistoryItems()
            state.didFail = false
        } catch {
            state.didFail = true
        }
    }
    
    /// Fetches channels.
    private func reloadRSSChannels() {
        effectManager.run {
            self.state.isLoading = true
            self.state.rssChannels = await self.getRSSChannelsUseCase.getRSSChannels(historyItems: self.state.historyItems)
            self.state.isLoading = false
        }
    }
}

// MARK: - State & Action -

extension RSSChannelListViewModel {
    public struct State: Equatable {
        // Data state
        var historyItems = [RSSHistoryItem]()
        var rssChannels = [UUID : Result<RSSChannel, RSSChannelError>]()
        var didFail = false
        var isLoading = false
        var isShowingFavourites: Bool

        public init(isShowingFavourites: Bool = false, historyItems: [RSSHistoryItem], rssChannels: [UUID : Result<RSSChannel, RSSChannelError>]) {
            self.historyItems = historyItems
            self.rssChannels = rssChannels
            self.isShowingFavourites = isShowingFavourites
        }
        
        // View
        let title = "rss_list_title".localized
        var status: ViewStatus {
            if isLoading {
                return .loading()
            }
            if didFail {
                return .error()
            } else {
                // RSSChannelListCellStateMapper is pure, no need to inject
                let cellStates = RSSChannelListCellStateMapper().map(historyItems: historyItems,
                                                                     rssChannels: rssChannels,
                                                                     isShowingFavourites: isShowingFavourites)
                if cellStates.isEmpty {
                    let message = isShowingFavourites ? "rss_list_no_favourites".localized : "rss_list_no_channels".localized
                    return .empty(text: message)
                } else {
                    return .loaded(states: cellStates)
                }
            }
        }
    }
    
    public enum ViewStatus: Equatable {
        case empty(text: String)
        case loading(text: String = "common_loading".localized)
        case loaded(states: [RSSChannelListCell.State])
        case error(text: String = "rss_list_channel_failure".localized)
    }
    
    public enum Action: Equatable {
        case onFirstAppear
        case didTapAddChannelButton
        case didTapRemoveHistoryItem(_ id: UUID)
        case didInitiateRefresh
        case didSelectItem(_ historyItemID: UUID)
        case toggleFavourites
    }
}
