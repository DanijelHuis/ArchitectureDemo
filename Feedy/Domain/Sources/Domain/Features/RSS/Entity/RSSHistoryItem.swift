//
//  RSSChannelHistoryItem.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import Foundation

public struct RSSHistoryItem: Codable, Equatable {
    public let id: UUID
    public let channelURL: URL
    public var isFavourite: Bool = false
    
    public init(id: UUID, channelURL: URL, isFavourite: Bool = false) {
        self.id = id
        self.channelURL = channelURL
        self.isFavourite = isFavourite
    }
}
