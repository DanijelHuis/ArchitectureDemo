//
//  RSSItem.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import Foundation

public struct RSSItem: Decodable, Equatable {
    public let guid: String?
    public let title: String?
    public let description: String?
    public let link: URL?
    public let imageURL: URL?
    public let pubDate: Date?
    
    public init(guid: String?, title: String?, description: String?, link: URL?, imageURL: URL?, pubDate: Date?) {
        self.guid = guid
        self.title = title
        self.description = description
        self.link = link
        self.imageURL = imageURL
        self.pubDate = pubDate
    }
}
