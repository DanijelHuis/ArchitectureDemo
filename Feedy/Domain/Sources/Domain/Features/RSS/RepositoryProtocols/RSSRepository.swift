//
//  RSSRepository.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import Foundation

public protocol RSSRepository {
    func getRSSChannel(url: URL) async throws -> RSSChannel
    func getRSSChannels(historyItems: [RSSHistoryItem]) async -> [UUID: Result<RSSChannel, RSSChannelError>]
}
