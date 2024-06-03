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
    // Private
    // rssHistoryItem and rssChannel objects are not part of the view state so we keep them here. View state should have only
    // formatted data that is needed for presenting the view. This is not ideal as this data and view formatted data can get de-synced
    // if not careful. I don't consider this huge problem as data like this could also be stored in cache, datasource, reactive stream or something else, that
    // means that de-sync is always possible. Our only source of truth here is the view state.
    private var rssHistoryItem: RSSHistoryItem
    private var rssChannel: RSSChannel
    private var cancellables: Set<AnyCancellable> = []

    public init(rssHistoryItem: RSSHistoryItem, rssChannel: RSSChannel, getRSSHistoryItemsUseCase: GetRSSHistoryItemsUseCase, getRSSChannelUseCase: GetRSSChannelUseCase, changeHistoryItemFavouriteStatusUseCase: ChangeHistoryItemFavouriteStatusUseCase, updateLastReadItemIDUseCase: UpdateLastReadItemIDUseCase, effectManager: SideEffectManager, coordinator: Coordinator) {
        self.rssHistoryItem = rssHistoryItem
        self.rssChannel = rssChannel
        self.getRSSHistoryItemsUseCase = getRSSHistoryItemsUseCase
        self.getRSSChannelUseCase = getRSSChannelUseCase
        self.changeHistoryItemFavouriteStatusUseCase = changeHistoryItemFavouriteStatusUseCase
        self.updateLastReadItemIDUseCase = updateLastReadItemIDUseCase
        self.effectManager = effectManager
        self.coordinator = coordinator
        self.state = .init(title: rssChannel.title, isFavourite: rssHistoryItem.isFavourite)
        observeEnvironment()
    }
    
    private func observeEnvironment() {
        // Observing for changes in favourite state
        getRSSHistoryItemsUseCase.output.sink { [weak self] event in
            guard let self else { return }
            // We can just update on every change, no need to check reason or item id.
            guard let historyItem = event.historyItems.first(where: { $0.id == self.rssHistoryItem.id }) else { return }
            self.rssHistoryItem = historyItem
            // View state (isFavourite) should be set from the view model rather than having it computed inside state from the history item.
            self.state.isFavourite = historyItem.isFavourite
        }.store(in: &cancellables)
    }
    
    public func send(_ action: Action) {
        switch action {
        case .onFirstAppear:
            loadRSSChannel(showLoading: true)
            
        case .didInitiateRefresh:
            loadRSSChannel(showLoading: false)
            
        case .toggleFavourites:
            let isFavourite = !self.rssHistoryItem.isFavourite
            try? self.changeHistoryItemFavouriteStatusUseCase.changeFavouriteStatus(historyItemID: self.rssHistoryItem.id, isFavourite: isFavourite)
                
        case .didTapOnRSSItem(let link):
            guard let link else { return }
            coordinator.openRoute(.common(.safari(url: link)))
        }
    }
    
    private func loadRSSChannel(showLoading: Bool) {
        effectManager.run {
            if showLoading {
                self.state.status = .loading()
            }
            
            // Ignoring error intentionally, we already have channel loaded so if it fails just show old one.
            self.rssChannel = (try? await self.getRSSChannelUseCase.getRSSChannel(url: self.rssHistoryItem.channelURL)) ?? self.rssChannel
            // Updates title
            self.state.title = self.rssChannel.title
            // Updagin last read item here
            self.updateLastReadItemID(historyItemID: self.rssHistoryItem.id, channel: self.rssChannel)
            // For simplicity, mapper is not injected.
            let cellStates = RSSChannelItemListCellStateMapper().map(rssItems: self.rssChannel.items)
            if !cellStates.isEmpty {
                self.state.status = .loaded(states: cellStates)
            } else {
                self.state.status = .empty()
            }
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
        // View
        // IMPORTANT: these properties could be computed (from the data values) but we want state to be dumb, otherwise we would have to format and do everything else, better keep that logic in the view model.
        var title: String?
        var isFavourite: Bool
        var status: ViewStatus
        
        public init(title: String? = nil, isFavourite: Bool = false, status: ViewStatus = .loading()) {
            self.title = title
            self.isFavourite = isFavourite
            self.status = status
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
