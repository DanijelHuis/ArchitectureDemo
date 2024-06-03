//
//  RSSHistoryRepository.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import Foundation
import Domain

/// Manages history items, uses `PersistenceManager` for persistence.
public final class DefaultRSSHistoryRepository: RSSHistoryRepository {
    private struct Constants {
        static let channelsPersistenceKey = "RSSHistoryRepository.channelsPersistenceKey"
    }
    private let persistenceManager: PersistenceManager
    
    public init(persistenceManager: PersistenceManager) {
        self.persistenceManager = persistenceManager
    }
    
    /// Simply loads and returns items.
    public func getRSSHistoryItems() throws -> [RSSHistoryItem]? {
        try persistenceManager.load(key: Constants.channelsPersistenceKey, type: [RSSHistoryItem].self)
    }
    
    /// Loads all items and returns the one with same id.
    public func getRSSHistoryItem(id: UUID) throws -> RSSHistoryItem {
        guard let historyItem = try getRSSHistoryItems()?.first(where: { $0.id == id }) else { throw RSSHistoryRepositoryError.historyItemNotFound }
        return historyItem
    }
    
    /// Adds item and returns updated items.
    public func addRSSHistoryItem(_ historyItem: RSSHistoryItem) throws -> [RSSHistoryItem] {
        var historyItems = (try getRSSHistoryItems()) ?? []
        guard !historyItems.contains(where: { $0.channelURL == historyItem.channelURL }) else { throw RSSHistoryRepositoryError.urlAlreadyExists }
        historyItems.append(historyItem)
        try save(historyItems: historyItems)
        return historyItems
    }
    
    /// Adds item and returns updated items.
    public func removeRSSHistoryItem(historyItemID: UUID) throws -> [RSSHistoryItem] {
        var historyItems = (try getRSSHistoryItems()) ?? []
        historyItems = historyItems.filter({ $0.id != historyItemID })
        try save(historyItems: historyItems)
        return historyItems
    }
    
    /// Replaces item with same id with given `historyItem`.
    public func updateRSSHistoryItem(_ historyItem: RSSHistoryItem) throws -> [RSSHistoryItem] {
        var historyItems = (try getRSSHistoryItems()) ?? []
        guard let index = historyItems.firstIndex(where: { $0.id == historyItem.id }) else { throw RSSHistoryRepositoryError.historyItemNotFound }
        historyItems[index] = historyItem
        try save(historyItems: historyItems)
        return historyItems
    }
    
    private func save(historyItems: [RSSHistoryItem]) throws {
        try persistenceManager.save(historyItems, forKey: Constants.channelsPersistenceKey)
    }
}
