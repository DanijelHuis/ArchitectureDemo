//
//  RSSHistoryManager.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import Foundation
import Combine

/// Provides reactive component and business logic over RSSHistoryRepository.
public class RSSHistoryManager: GetRSSHistoryItemsUseCase, AddRSSHistoryItemUseCase, RemoveRSSHistoryItemUseCase, ChangeHistoryItemFavouriteStatusUseCase, UpdateLastReadItemIDUseCase {
    private let repository: RSSHistoryRepository
    private let subject = PassthroughSubject<RSSHistoryEvent, Never>()
    public var output: AnyPublisher<RSSHistoryEvent, Never> { subject.eraseToAnyPublisher() }
    
    public init(repository: RSSHistoryRepository) {
        self.repository = repository
    }
    
    /// Loads items and sends `.update` event.
    public func getRSSHistoryItems() throws {
        let historyItems = (try repository.getRSSHistoryItems()) ?? []
        subject.send(.init(reason: .update, historyItems: historyItems))
    }
    
    /// Creates new item, adds it and sends `.add` event.
    public func addRSSHistoryItem(channelURL: URL) throws {
        let historyItemID = UUID()
        let historyItems = try repository.addRSSHistoryItem(.init(id: historyItemID, channelURL: channelURL))
        subject.send(.init(reason: .add(historyItemID: historyItemID), historyItems: historyItems))
    }
    
    /// Removes item and sends `.add` event
    public func removeRSSHistoryItem(_ historyItemID: UUID) throws {
        let historyItems = try repository.removeRSSHistoryItem(historyItemID: historyItemID)
        subject.send(.init(reason: .remove(historyItemID: historyItemID), historyItems: historyItems))
    }
    
    /// Changes favourite status o and sends `.favouriteStatusUpdated` event.
    public func changeFavouriteStatus(historyItemID: UUID, isFavourite: Bool) throws {
        var historyItem = try repository.getRSSHistoryItem(id: historyItemID)
        historyItem.isFavourite = isFavourite
        let historyItems = try repository.updateRSSHistoryItem(historyItem)
        subject.send(.init(reason: .favouriteStatusUpdated(historyItemID: historyItemID), historyItems: historyItems))
    }
    
    /// Updates lastReadItemID and sends `didUpdateLastReadItemID` event.
    public func updateLastReadItemID(historyItemID: UUID, lastItemID: String) throws {
        var historyItem = try repository.getRSSHistoryItem(id: historyItemID)
        // Don't update if it didn't change.
        guard historyItem.lastReadItemID != lastItemID else { return }
        historyItem.lastReadItemID = lastItemID
        let historyItems = try repository.updateRSSHistoryItem(historyItem)
        subject.send(.init(reason: .didUpdateLastReadItemID(historyItemID: historyItemID), historyItems: historyItems))
    }
}
