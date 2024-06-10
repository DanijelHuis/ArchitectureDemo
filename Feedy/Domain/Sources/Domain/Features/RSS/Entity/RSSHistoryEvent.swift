//
//  RSSHistoryEvent.swift
//  Feedy
//
//  Created by Danijel Huis on 18.05.2024..
//

import Foundation

public struct RSSHistoryEvent: Equatable {
    public let reason: Reason
    public let channels: [RSSChannelResponse]
    
    public init(reason: Reason, channels: [RSSChannelResponse]) {
        self.reason = reason
        self.channels = channels
    }
    
    public enum Reason: Equatable {
        case update
        case add(historyItemID: UUID)
        case remove(historyItemID: UUID)
        case favouriteStatusUpdated(historyItemID: UUID)
    }
}
