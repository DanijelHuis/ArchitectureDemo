//
//  EntityMocks.swift
//
//
//  Created by Danijel Huis on 07.06.2024..
//

import Foundation

public extension RSSHistoryItem {
    static func mock(id: UUID = UUID(),
                     channelURL: URL = URL(string: "https://history")!,
                     isFavourite: Bool = false) -> RSSHistoryItem {
        .init(id: id, channelURL: channelURL, isFavourite: isFavourite)
    }
}

public extension RSSChannel {
    static func mock(title: String = UUID().uuidString,
                     description: String = UUID().uuidString,
                     imageURL: URL? = URL(string: "https://channel")!,
                     items: [RSSItem] = [.mock(), .mock()]) -> RSSChannel {
        .init(title: title, description: description, imageURL: imageURL, items: items)
    }
}

public extension RSSItem {
    static func mock(guid: String = UUID().uuidString,
                     title: String? = UUID().uuidString,
                     description: String? = UUID().uuidString,
                     link: URL? = URL(string: "https://item_link")!,
                     imageURL: URL? = URL(string: "https://item_imageURL")!,
                     pubDate: Date? = Date(timeIntervalSinceReferenceDate: 0)) -> RSSItem {
        .init(guid: guid, title: title, description: description, link: link, imageURL: imageURL, pubDate: pubDate)
    }
}

