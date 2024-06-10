//
//  RSSManager.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import Foundation
import Combine

/// Provides reactive component and business logic over RSSHistoryRepository.
public class RSSManager: GetRSSChannelsUseCase, AddRSSHistoryItemUseCase, RemoveRSSHistoryItemUseCase, ChangeHistoryItemFavouriteStatusUseCase {
    private let historyRepository: RSSHistoryRepository
    private let rssRepository: RSSRepository
    private let subject = PassthroughSubject<[RSSChannelResponse], Never>()
    @MainActor private var channelsCache = [UUID: Result<RSSChannel, RSSChannelError>]()
    public var output: AnyPublisher<[RSSChannelResponse], Never> { subject.eraseToAnyPublisher() }
    
    public init(historyRepository: RSSHistoryRepository, rssRepository: RSSRepository) {
        self.historyRepository = historyRepository
        self.rssRepository = rssRepository
    }
        
    /// Loads history items and fetches RSS channels.
    public func getRSSChannels() async throws {
        let historyItems = try historyRepository.getRSSHistoryItems()
        await getChannels(historyItems: historyItems ?? [], reload: true)
    }
    
    /// Adds history item and fetches RSS channels for all items.
    public func addRSSHistoryItem(channelURL: URL) async throws {
        let historyItems = try historyRepository.addRSSHistoryItem(.init(id: UUID(), channelURL: channelURL))
        await getChannels(historyItems: historyItems, reload: true)
    }
    
    /// Removes history item, doesn't fetch RSS channels.
    public func removeRSSHistoryItem(_ historyItemID: UUID) async throws {
        let historyItems = try historyRepository.removeRSSHistoryItem(historyItemID: historyItemID)
        await getChannels(historyItems: historyItems, reload: false)
    }
    
    /// Replaces history item, doesn't fetch RSS channels.
    public func changeFavouriteStatus(historyItemID: UUID, isFavourite: Bool) async throws {
        var historyItem = try historyRepository.getRSSHistoryItem(id: historyItemID)
        historyItem.isFavourite = isFavourite
        let historyItems = try historyRepository.updateRSSHistoryItem(historyItem)
        await getChannels(historyItems: historyItems, reload: false)
    }
    
    // MARK: - Private -
    
    @MainActor
    private func getChannels(historyItems: [RSSHistoryItem], reload: Bool) async {
        // Checking for isEmpty just to be safe, if no history items then it won't load anything.
        if reload || channelsCache.isEmpty {
            channelsCache = await rssRepository.getRSSChannels(historyItems: historyItems)
        }
        
        let channels = historyItems.reduce(into: [RSSChannelResponse]()) { partialResult, historyItem in
            partialResult.append(.init(historyItem: historyItem, channel: channelsCache[historyItem.id]))
        }
        subject.send(channels)
    }
}
