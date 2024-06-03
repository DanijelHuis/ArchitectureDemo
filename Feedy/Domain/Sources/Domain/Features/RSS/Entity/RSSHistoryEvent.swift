//
//  RSSHistoryEvent.swift
//  Feedy
//
//  Created by Danijel Huis on 18.05.2024..
//

import Foundation

public struct RSSHistoryEvent: Equatable {
    public let reason: Reason
    public let historyItems: [RSSHistoryItem]
    
    public init(reason: Reason, historyItems: [RSSHistoryItem]) {
        self.reason = reason
        self.historyItems = historyItems
    }
    
    public enum Reason: Equatable {
        case update
        case add(historyItemID: UUID)
        case remove(historyItemID: UUID)
        case favouriteStatusUpdated(historyItemID: UUID)
        case didUpdateLastReadItemID(historyItemID: UUID)
    }
}
