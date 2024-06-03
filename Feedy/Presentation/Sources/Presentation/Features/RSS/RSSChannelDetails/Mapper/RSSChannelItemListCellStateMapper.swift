//
//  RSSChannelItemListCellStateMapper.swift
//
//
//  Created by Danijel Huis on 20.05.2024..
//

import Foundation
import Domain

struct RSSChannelItemListCellStateMapper {
    private let locale: Locale
    private let timeZone: TimeZone
    private let format: Date.FormatStyle
    
    init(locale: Locale = .autoupdatingCurrent, timeZone: TimeZone = TimeZone.current) {
        self.locale = locale
        self.timeZone = timeZone
        var format = Date.FormatStyle.dateTime
            .day().month(.wide).year()
            .hour().minute()
            .locale(locale)
        format.timeZone = timeZone
        self.format = format
    }
    
    func map(rssItems: [RSSItem]) -> [RSSChannelItemListCell.State] {
        rssItems.map {
            let dateString = $0.pubDate.map { $0.formatted(format) }
            return RSSChannelItemListCell.State(id: $0.guid ?? UUID().uuidString,
                                                link: $0.link,
                                                title: $0.title,
                                                publishDate: dateString,
                                                description: $0.description,
                                                imageURL: $0.imageURL)
        }
    }
}
