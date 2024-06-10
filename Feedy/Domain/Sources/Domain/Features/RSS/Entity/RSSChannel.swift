//
//  RSSChannel.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import Foundation

public struct RSSChannel: Decodable, Equatable {
    public let title: String
    public let description: String
    public let imageURL: URL?
    public let items: [RSSItem]
    
    public init(title: String, description: String, imageURL: URL?, items: [RSSItem]) {
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.items = items
    }
}
