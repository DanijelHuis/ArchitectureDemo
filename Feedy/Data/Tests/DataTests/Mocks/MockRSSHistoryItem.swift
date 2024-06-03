//
//  MockRSSHistoryItem.swift
//
//
//  Created by Danijel Huis on 20.05.2024..
//

import Foundation
import Domain

extension RSSHistoryItem {
    static func mock(id: UUID = UUID(),
                     channelURL: URL = URL(string: "https://history")!,
                     isFavourite: Bool = false) -> RSSHistoryItem {
        .init(id: id, channelURL: channelURL, isFavourite: isFavourite)
    }
}
