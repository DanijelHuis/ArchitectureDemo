//
//  RSSHistoryRepository.swift
//
//
//  Created by Danijel Huis on 19.05.2024..
//

import Foundation

public protocol RSSHistoryRepository {
    func getRSSHistoryItems() throws -> [RSSHistoryItem]?
    func getRSSHistoryItem(id: UUID) throws -> RSSHistoryItem
    func addRSSHistoryItem(_ historyItem: RSSHistoryItem) throws -> [RSSHistoryItem]
    func removeRSSHistoryItem(historyItemID: UUID) throws -> [RSSHistoryItem]
    func updateRSSHistoryItem(_ historyItem: RSSHistoryItem) throws -> [RSSHistoryItem]
}

public enum RSSHistoryRepositoryError: Error {
    case historyItemNotFound
    case urlAlreadyExists
}
