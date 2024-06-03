//
//  RSSChannelListCellState+Mapper.swift
//
//
//  Created by Danijel Huis on 20.05.2024..
//

import Foundation
import Domain

struct RSSChannelListCellStateMapper {
    func map(historyItems: [RSSHistoryItem], rssChannels: [UUID : Result<RSSChannel, RSSChannelError>], isShowingFavourites: Bool) -> [RSSChannelListCell.State] {
        historyItems.reduce(into: [RSSChannelListCell.State]()) { partialResult, historyItem in
            let channelResult = rssChannels[historyItem.id]
            guard !isShowingFavourites || historyItem.isFavourite else { return }
            
            switch channelResult {
            case .success(let rssChannel):
                partialResult.append(.init(historyItemID: historyItem.id,
                                           title: rssChannel.title,
                                           description: rssChannel.description,
                                           imageResource: .init(url: rssChannel.imageURL, placeholderSystemName: "newspaper"),
                                           isFavourite: historyItem.isFavourite))
            case .failure, .none:
                partialResult.append(.init(historyItemID: historyItem.id,
                                           title: "rss_list_failed_to_load_channel".localized,
                                           description: historyItem.channelURL.absoluteString,
                                           imageResource: .init(url: nil, placeholderSystemName: "exclamationmark.triangle"),
                                           isFavourite: historyItem.isFavourite))
            }
        }
    }
}
