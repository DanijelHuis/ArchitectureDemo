//
//  RemoteRSSChannelResponse.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import Foundation

/// Spec: https://www.rssboard.org/rss-specification
struct RemoteRSSChannelResponse: Decodable {
    let channel: RemoteRSSChannel
}
