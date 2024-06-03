//
//  MockUseCases.swift
//
//
//  Created by Danijel Huis on 20.05.2024..
//

import Foundation
import Domain
import TestUtility
import Combine
@testable import Presentation

final class MockGetRSSChannelsUseCase: GetRSSChannelsUseCase {
    var getRSSChannelsCalls = [[RSSHistoryItem]]()
    var getRSSChannelsResult = [UUID : Result<Domain.RSSChannel, RSSChannelError>]()
    func getRSSChannels(historyItems: [Domain.RSSHistoryItem]) async -> [UUID : Result<Domain.RSSChannel, RSSChannelError>] {
        getRSSChannelsCalls.append(historyItems)
        return getRSSChannelsResult
    }
}

final class MockAddRSSHistoryItemUseCase: AddRSSHistoryItemUseCase {
    var addRSSHistoryItemCalls = [URL]()
    var addRSSHistoryItemError: Error?
    func addRSSHistoryItem(channelURL: URL) throws {
        addRSSHistoryItemCalls.append(channelURL)
        if let addRSSHistoryItemError {
            throw addRSSHistoryItemError
        }
    }
}

final class MockChangeHistoryItemFavouriteStatusUseCase: ChangeHistoryItemFavouriteStatusUseCase {
    var changeFavouriteStatusCalls = [(historyItemID: UUID, isFavourite: Bool)]()
    var changeFavouriteStatusError: Error?
    func changeFavouriteStatus(historyItemID: UUID, isFavourite: Bool) throws {
        changeFavouriteStatusCalls.append((historyItemID, isFavourite))
        if let changeFavouriteStatusError {
            throw changeFavouriteStatusError
        }
    }
}

final class MockGetRSSChannelUseCase: GetRSSChannelUseCase {
    var getRSSChannelCalls = [URL]()
    var getRSSChannelResult: Result<RSSChannel, Error> = .failure(MockError.mockNotSetup)
    func getRSSChannel(url: URL) async throws -> RSSChannel {
        getRSSChannelCalls.append(url)
        return try getRSSChannelResult.get()
    }
}

final class MockGetRSSHistoryItemsUseCase: GetRSSHistoryItemsUseCase {
    var subject = PassthroughSubject<RSSHistoryEvent, Never>()
    var output: AnyPublisher<Domain.RSSHistoryEvent, Never> { subject.eraseToAnyPublisher() }
    var eventToEmit: RSSHistoryEvent?
    
    var getRSSHistoryItemsCalls = 0
    var getRSSHistoryItemsError: Error?
    func getRSSHistoryItems() throws {
        getRSSHistoryItemsCalls += 1
        if let getRSSHistoryItemsError {
            throw getRSSHistoryItemsError
        }
        if let eventToEmit {
            subject.send(eventToEmit)
        }
    }
}

final class MockRemoveRSSHistoryItemUseCase: RemoveRSSHistoryItemUseCase {
    var removeRSSHistoryItemCalls = [UUID]()
    var removeRSSHistoryItemError: Error?
    func removeRSSHistoryItem(_ historyItemID: UUID) throws {
        removeRSSHistoryItemCalls.append(historyItemID)
        if let removeRSSHistoryItemError {
            throw removeRSSHistoryItemError
        }
    }
}

final class MockValidateRSSChannelUseCase: ValidateRSSChannelUseCase {
    var validateRSSChannelCalls = [URL]()
    var validateRSSChannelResult = false
    func validateRSSChannel(url: URL) async -> Bool {
        validateRSSChannelCalls.append(url)
        return validateRSSChannelResult
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
