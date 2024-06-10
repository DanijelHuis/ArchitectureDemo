//
//  RSSChannelResponse.swift
//
//
//  Created by Danijel Huis on 10.06.2024..
//

import Foundation

public struct RSSChannelResponse: Equatable {
    public let historyItem: RSSHistoryItem
    public let channel: Result<RSSChannel, RSSChannelError>?
    
    public init(historyItem: RSSHistoryItem, channel: Result<RSSChannel, RSSChannelError>?) {
        self.historyItem = historyItem
        self.channel = channel
    }
}
