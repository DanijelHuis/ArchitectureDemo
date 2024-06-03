//
//  RSSChannelListViewModel.swift
//  Feedy
//
//  Created by Danijel Huis on 18.05.2024..
//

import Foundation
import Combine
import Domain
import Localization
import SwiftUI

@MainActor public final class RSSChannelListViewModel: SwiftUIViewModel {
    // Dependencies
    private let getRSSHistoryItemsUseCase: GetRSSHistoryItemsUseCase
    private let removeRSSHistoryItemUseCase: RemoveRSSHistoryItemUseCase
    private let getRSSChannelsUseCase: GetRSSChannelsUseCase
    private let coordinator: Coordinator
    public let effectManager: SideEffectManager
    @Published public private(set) var state: State = State()
    
    // Private
    private var cancellables: Set<AnyCancellable> = []
    // historyItems and rssChannels objects are not part of the view state so we keep them here. View state should have only
    // formatted data that is needed for presenting the view. This is not ideal as this data and view formatted data can get de-synced
    // if not careful. I don't consider this huge problem as data like this could also be stored in cache, datasource, reactive stream or something else, that
    // means that de-sync is always possible. Our only source of truth here is the view state.
    private var historyItems = [RSSHistoryItem]()
    private var rssChannels = [UUID : Result<RSSChannel, RSSChannelError>]()

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
            historyItems = event.historyItems
            
            // We need to reload RSS channels only if they were updated or new one is added, otherwise we can just referesh the list.
            switch event.reason {
            case .update, .add:
                reloadRSSChannels()
            case .remove, .favouriteStatusUpdated:
                refreshList()
            case .didUpdateLastReadItemID:
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
            guard let historyItem = self.historyItems.first(where: { $0.id == historyItemID }) else { return }
            guard let channelResult = self.rssChannels[historyItemID] else { return }
            guard case let .success(channel) = channelResult else { return }
            coordinator.openRoute(.rss(.details(rssHistoryItem: historyItem, channel: channel)))
        
        case .toggleFavourites:
            state.isShowingFavourites.toggle()
            refreshList()
        }
    }
    
    /// This will trigger getRSSHistoryItemsUseCase which will then reload and refresh.
    private func getHistoryItems() {
        do {
            try self.getRSSHistoryItemsUseCase.getRSSHistoryItems()
        } catch {
            state.status = .error()
        }
    }
    
    /// Fetches channels and refreshes the list.
    private func reloadRSSChannels() {
        effectManager.run {
            let historyItems = self.historyItems
            guard !historyItems.isEmpty else {
                self.state.status = .empty(text: "rss_list_no_channels".localized)
                return
            }
            self.rssChannels = await self.getRSSChannelsUseCase.getRSSChannels(historyItems: historyItems)
            self.refreshList()
        }
    }
    
    private func refreshList() {
        // For simplicity, mapper is not injected (it is pure).
        let cellStates = RSSChannelListCellStateMapper().map(historyItems: self.historyItems,
                                                             rssChannels: self.rssChannels,
                                                             isShowingFavourites: self.state.isShowingFavourites)
        if !cellStates.isEmpty {
            state.status = .loaded(states: cellStates)
        } else {
            let message = self.state.isShowingFavourites ? "rss_list_no_favourites".localized : "rss_list_no_channels".localized
            state.status = .empty(text: message)
        }
    }
}

// MARK: - State & Action -

extension RSSChannelListViewModel {
    public struct State: Equatable {
        // View
        let title = "rss_list_title".localized
        var isShowingFavourites: Bool
        var status: ViewStatus

        public init(isShowingFavourites: Bool = false, status: ViewStatus = .loading()) {
            self.isShowingFavourites = isShowingFavourites
            self.status = status
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

enum RSSChannelListDisplayType {
    case all
    case favourites
}

extension RSSChannelListDisplayType {
    mutating func toggle() {
        switch self {
        case .all: self = .favourites
        case .favourites: self = .all
        }
    }
}



