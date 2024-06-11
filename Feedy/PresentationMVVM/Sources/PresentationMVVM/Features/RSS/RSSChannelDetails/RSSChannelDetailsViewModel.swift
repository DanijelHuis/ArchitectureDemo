//
//  RSSChannelDetailsViewModel.swift
//  Feedy
//
//  Created by Danijel Huis on 11.06.2024..
//

import Foundation
import Combine
import Domain
import CommonUI

@Observable @MainActor public final class RSSChannelDetailsViewModel {
    // Dependencies
    private let getRSSChannelsUseCase: GetRSSChannelsUseCase
    private let getRSSChannelUseCase: GetRSSChannelUseCase
    private let changeHistoryItemFavouriteStatusUseCase: ChangeHistoryItemFavouriteStatusUseCase
    private let coordinator: Coordinator
    public let effectManager: EffectManager
    
    private var cancellables: Set<AnyCancellable> = []
    public init(rssHistoryItem: RSSHistoryItem, rssChannel: RSSChannel, getRSSChannelsUseCase: GetRSSChannelsUseCase, getRSSChannelUseCase: GetRSSChannelUseCase, changeHistoryItemFavouriteStatusUseCase: ChangeHistoryItemFavouriteStatusUseCase, effectManager: EffectManager, coordinator: Coordinator) {
        self.getRSSChannelsUseCase = getRSSChannelsUseCase
        self.getRSSChannelUseCase = getRSSChannelUseCase
        self.changeHistoryItemFavouriteStatusUseCase = changeHistoryItemFavouriteStatusUseCase
        self.effectManager = effectManager
        self.coordinator = coordinator
        self.rssHistoryItem = rssHistoryItem
        self.rssChannel = rssChannel
        
        observeEnvironment()
    }
    
    private func observeEnvironment() {
        // Observing for changes in favourite state
        getRSSChannelsUseCase.output.sink { [weak self] channels in
            guard let self else { return }
            guard let channelResponse = channels.first(where: { $0.historyItem.id == self.rssHistoryItem.id }) else { return }
            self.rssHistoryItem = channelResponse.historyItem
        }.store(in: &cancellables)
    }
    
    // MARK: - Actions -
    
    func onFirstAppear() {
        effectManager.run {
            await self.loadRSSChannel(showLoading: true)
        }
    }
    
    func didInitiateRefresh() async {
        await loadRSSChannel(showLoading: false)
    }
    
    func toggleFavourites() {
        self.effectManager.run {
            let isFavourite = !self.rssHistoryItem.isFavourite
            try? await self.changeHistoryItemFavouriteStatusUseCase.changeFavouriteStatus(historyItemID: self.rssHistoryItem.id, isFavourite: isFavourite)
        }
    }
    
    func didTapOnRSSItem(link: URL?) {
        guard let link else { return }
        coordinator.openRoute(.common(.safari(url: link)))
    }

    // MARK: - Private -
    
    private func loadRSSChannel(showLoading: Bool) async {
        // Note: Might be better to add this to RSSManager so channel is updated.
        if showLoading { self.isLoading = true }
        defer { self.isLoading = false }
        
        // Ignoring error intentionally, we already have channel loaded so if it fails just show old one.
        self.rssChannel = (try? await self.getRSSChannelUseCase.getRSSChannel(url: self.rssHistoryItem.channelURL)) ?? self.rssChannel
    }
    
    // MARK: - View state -
    
    var rssHistoryItem: RSSHistoryItem
    var rssChannel: RSSChannel
    var isLoading: Bool = false
    var title: String? { rssChannel.title }
    var isFavourite: Bool { rssHistoryItem.isFavourite }
            
    var status: ViewStatus {
        let items = rssChannel.items.map({ RSSChannelItemListCell.State(rssItem: $0) })
        if isLoading {
            return .loading()
        } else if items.isEmpty {
            return .empty()
        } else {
            return .loaded(states: items)
        }
    }
}

// MARK: - State & Action -

extension RSSChannelDetailsViewModel {    
    public enum ViewStatus: Equatable {
        case empty(text: String = "rss_details_no_items".localized)
        case loading(text: String = "common_loading".localized)
        case loaded(states: [RSSChannelItemListCell.State])
    }
}
