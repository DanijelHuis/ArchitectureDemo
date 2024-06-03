//
//  MockRSSHistoryRepository.swift
//
//
//  Created by Danijel Huis on 20.05.2024..
//

import Foundation
import Domain
import TestUtility

final class MockRSSHistoryRepository: RSSHistoryRepository {
    
    var getRSSHistoryItemsCalls = 0
    var getRSSHistoryItemsResult: Result<[RSSHistoryItem]?, Error> = .failure(MockError.mockNotSetup)
    func getRSSHistoryItems() throws -> [Domain.RSSHistoryItem]? {
        getRSSHistoryItemsCalls += 1
        return try getRSSHistoryItemsResult.get()
    }
    
    var getRSSHistoryItemCalls = [UUID]()
    var getRSSHistoryItemResult: Result<RSSHistoryItem, Error> = .failure(MockError.mockNotSetup)
    func getRSSHistoryItem(id: UUID) throws -> Domain.RSSHistoryItem {
        getRSSHistoryItemCalls.append(id)
        return try getRSSHistoryItemResult.get()
    }
    
    var addRSSHistoryItemCalls = [RSSHistoryItem]()
    var addRSSHistoryItemResult: Result<[RSSHistoryItem], Error> = .failure(MockError.mockNotSetup)
    func addRSSHistoryItem(_ historyItem: Domain.RSSHistoryItem) throws -> [Domain.RSSHistoryItem] {
        addRSSHistoryItemCalls.append(historyItem)
        return try addRSSHistoryItemResult.get()
    }
    
    var removeRSSHistoryItemCalls = [UUID]()
    var removeRSSHistoryItemResult: Result<[RSSHistoryItem], Error> = .failure(MockError.mockNotSetup)
    func removeRSSHistoryItem(historyItemID: UUID) throws -> [Domain.RSSHistoryItem] {
        removeRSSHistoryItemCalls.append(historyItemID)
        return try removeRSSHistoryItemResult.get()
    }
    
    var updateRSSHistoryItemCalls = [RSSHistoryItem]()
    var updateRSSHistoryItemResult: Result<[RSSHistoryItem], Error> = .failure(MockError.mockNotSetup)
    func updateRSSHistoryItem(_ historyItem: Domain.RSSHistoryItem) throws -> [Domain.RSSHistoryItem] {
        updateRSSHistoryItemCalls.append(historyItem)
        return try updateRSSHistoryItemResult.get()
    }
}
