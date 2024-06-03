//
//  GetRSSChannelsUseCase.swift
//  Feedy
//
//  Created by Danijel Huis on 18.05.2024..
//

import Foundation

public protocol GetRSSChannelsUseCase {
    func getRSSChannels(historyItems: [RSSHistoryItem]) async -> [UUID: Result<RSSChannel, RSSChannelError>]
}
