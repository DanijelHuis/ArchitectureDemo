//
//  MockUseCases.swift
//
//
//  Created by Danijel Huis on 21.05.2024..
//

import Foundation
import Domain

final class MockGetRSSChannelsUseCase: GetRSSChannelsUseCase {
    var getRSSChannelsCalls = [[RSSHistoryItem]]()
    var getRSSChannelsResult = [UUID : Result<Domain.RSSChannel, RSSChannelError>]()
    func getRSSChannels(historyItems: [Domain.RSSHistoryItem]) async -> [UUID : Result<Domain.RSSChannel, RSSChannelError>] {
        getRSSChannelsCalls.append(historyItems)
        return getRSSChannelsResult
    }
}

final class MockUpdateLastReadItemIDUseCase: UpdateLastReadItemIDUseCase {
    var updateLastReadItemIDCalls = [(historyItemID: UUID, lastItemID: String)]()
    var updateLastReadItemIDError: Error?
    func updateLastReadItemID(historyItemID: UUID, lastItemID: String) throws {
        updateLastReadItemIDCalls.append((historyItemID, lastItemID))
        if let updateLastReadItemIDError {
            throw updateLastReadItemIDError
        }
    }
}
