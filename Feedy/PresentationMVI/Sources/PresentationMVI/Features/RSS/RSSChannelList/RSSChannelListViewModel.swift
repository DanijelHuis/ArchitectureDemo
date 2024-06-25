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

@MainActor @Observable
public final class RSSChannelListViewModel: SwiftUIViewModel {
    // Dependencies
    private let getRSSChannelsUseCase: GetRSSChannelsUseCase
    private let removeRSSHistoryItemUseCase: RemoveRSSHistoryItemUseCase
    private let coordinator: Coordinator
    public let effectManager: EffectManager
    public private(set) var state: State = State(channels: [])
    // Private
    private var cancellables: Set<AnyCancellable> = []
    
    deinit {
        print("!!!Deinit \(type(of: self))")   //@DEBUG
    }
    
    public init(getRSSChannelsUseCase: GetRSSChannelsUseCase, removeRSSHistoryItemUseCase: RemoveRSSHistoryItemUseCase, effectManager: EffectManager, coordinator: Coordinator) {
        self.getRSSChannelsUseCase = getRSSChannelsUseCase
        self.removeRSSHistoryItemUseCase = removeRSSHistoryItemUseCase
        self.coordinator = coordinator
        self.effectManager = effectManager
        observeEnvironment()
    }
    
    private func observeEnvironment() {
        effectManager.runStream { [weak self, getRSSChannelsUseCase = getRSSChannelsUseCase] in
            // Using .values instead of .sink so we can keep everything protected by MainActor and test easily.
            for await channels in getRSSChannelsUseCase.output.values {
                guard let self else { return }
                state.channels = channels
            }
        }
    }
    
    public func send(_ action: Action) {
        switch action {
        case .onFirstAppear, .didTapRetry:
            effectManager.runTask {
                await self.getChannels(showLoading: true)
            }
            
        case .didInitiateRefresh:
            effectManager.runTask {
                await self.getChannels(showLoading: false)
            }
            
        case .didTapAddChannelButton:
            coordinator.openRoute(.rss(.add))
            
        case .didTapRemoveHistoryItem(let id):
            effectManager.runTask {
                try? await self.removeRSSHistoryItemUseCase.removeRSSHistoryItem(id)
            }
            
        case .didSelectItem(let historyItemID):
            guard let channelResponse = state.channels.first(where: { $0.historyItem.id == historyItemID }) else { return }
            guard case let .success(channel) = channelResponse.channel else { return }
            coordinator.openRoute(.rss(.details(rssHistoryItem: channelResponse.historyItem, channel: channel)))
            
        case .toggleFavourites:
            state.isShowingFavourites.toggle()
        }
    }
        
    private func getChannels(showLoading: Bool) async {
        if showLoading { state.isLoading = true }
        defer { state.isLoading = false }
        
        do {
            try await self.getRSSChannelsUseCase.getRSSChannels()
            state.didFail = false
        } catch {
            state.didFail = true
        }
    }
}

// MARK: - State & Action -

extension RSSChannelListViewModel {
    public struct State: Equatable {
        // Data state
        var channels = [RSSChannelResponse]()
        var didFail = false
        var isLoading = false
        var isShowingFavourites: Bool

        public init(isShowingFavourites: Bool = false, channels: [RSSChannelResponse]) {
            self.isShowingFavourites = isShowingFavourites
            self.channels = channels
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
    
    public enum ViewStatus: Equatable {
        case empty(text: String)
        case loading(text: String = "common_loading".localized)
        case loaded(states: [RSSChannelListCell.State])
        case error(text: String = "rss_list_channel_failure".localized, retryText: String = "common_retry".localized)
    }
    
    public enum Action: Equatable {
        case onFirstAppear
        case didTapAddChannelButton
        case didTapRetry
        case didTapRemoveHistoryItem(_ id: UUID)
        case didInitiateRefresh
        case didSelectItem(_ historyItemID: UUID)
        case toggleFavourites
    }
}
