//
//  RemoteRSSItem.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import Foundation

/// Spec: https://www.rssboard.org/rss-specification
struct RemoteRSSItem: Decodable {
    let guid: String?
    let title: String?
    let description: String?
    let link: URL?
    let enclosure: Enclosure?
    let pubDate: String?

    struct Enclosure: Decodable {
        let url: URL
        let type: String
    }
}
