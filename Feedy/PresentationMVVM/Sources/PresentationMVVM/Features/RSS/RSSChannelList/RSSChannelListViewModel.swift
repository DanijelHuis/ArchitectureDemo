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

@Observable @MainActor public final class RSSChannelListViewModel {
    // Dependencies
    private let getRSSChannelsUseCase: GetRSSChannelsUseCase
    private let removeRSSHistoryItemUseCase: RemoveRSSHistoryItemUseCase
    private let coordinator: Coordinator
    let effectManager: EffectManager
    // Private
    private var cancellables: Set<AnyCancellable> = []
    
    public init(getRSSChannelsUseCase: GetRSSChannelsUseCase, removeRSSHistoryItemUseCase: RemoveRSSHistoryItemUseCase, effectManager: EffectManager, coordinator: Coordinator) {
        self.getRSSChannelsUseCase = getRSSChannelsUseCase
        self.removeRSSHistoryItemUseCase = removeRSSHistoryItemUseCase
        self.coordinator = coordinator
        self.effectManager = effectManager
        observeEnvironment()
    }
    
    private func observeEnvironment() {
        getRSSChannelsUseCase.output.sink { [weak self] channels in
            guard let self else { return }
            self.channels = channels
        }.store(in: &cancellables)
    }
    
    func onFirstAppear() {
        effectManager.run {
            await self.getChannels(showLoading: true)
        }
    }
    
    func didTapRetry() {
        effectManager.run {
            await self.getChannels(showLoading: true)
        }
    }
        
    func didInitiateRefresh() async {
        await self.getChannels(showLoading: false)
    }
    
    func didTapAddChannelButton() {
        coordinator.openRoute(.rss(.add))
    }
    
    func didTapRemoveHistoryItem(historyItemID: UUID) {
        effectManager.run {
            try? await self.removeRSSHistoryItemUseCase.removeRSSHistoryItem(historyItemID)
        }
    }
    
    func didSelectItem(historyItemID: UUID) {
        guard let channelResponse = channels.first(where: { $0.historyItem.id == historyItemID }) else { return }
        guard case let .success(channel) = channelResponse.channel else { return }
        coordinator.openRoute(.rss(.details(rssHistoryItem: channelResponse.historyItem, channel: channel)))
    }
    
    func toggleFavourites() {
        isShowingFavourites.toggle()
    }
    
    private func getChannels(showLoading: Bool) async {
        if showLoading { isLoading = true }
        defer { isLoading = false }
        
        do {
            try await self.getRSSChannelsUseCase.getRSSChannels()
            didFail = false
        } catch {
            didFail = true
        }
    }
    
    // MARK: - View state -
    let title = "rss_list_title".localized
    var channels = [RSSChannelResponse]()
    var didFail = false
    var isLoading = false
    var isShowingFavourites = false
    
    var status: ViewStatus {
        if isLoading {
            return .loading()
        }
        if didFail {
            return .error()
        } else {
            // RSSChannelListCellStateMapper is pure, no need to inject
            let cellStates = RSSChannelListCellStateMapper().map(channels: channels, isShowingFavourites: isShowingFavourites)
            if cellStates.isEmpty {
                let message = isShowingFavourites ? "rss_list_no_favourites".localized : "rss_list_no_channels".localized
                return .empty(text: message)
            } else {
                return .loaded(states: cellStates)
            }
        }
    }
}

// MARK: - State & Action -

extension RSSChannelListViewModel {
    public enum ViewStatus: Equatable {
        case empty(text: String)
        case loading(text: String = "common_loading".localized)
        case loaded(states: [RSSChannelListCell.State])
        case error(text: String = "rss_list_channel_failure".localized, retryText: String = "common_retry".localized)
    }
}
