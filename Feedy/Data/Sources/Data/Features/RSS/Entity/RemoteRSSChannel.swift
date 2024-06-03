//
//  RemoteRSSChannel.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import Foundation

/// Spec: https://www.rssboard.org/rss-specification
struct RemoteRSSChannel: Decodable {
    let title: String
    let description: String
    let image: Image?
    let item: [RemoteRSSItem]?
    
    struct Image: Decodable {
        let url: URL?
    }
}
