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
@testable import PresentationMVVM

final class MockGetRSSChannelsUseCase: GetRSSChannelsUseCase {
    var subject = PassthroughSubject<[RSSChannelResponse], Never>()
    var output: AnyPublisher<[RSSChannelResponse], Never> { subject.eraseToAnyPublisher() }
        
    var channelsToEmit: [RSSChannelResponse]?
    var getRSSChannelsCalls = 0
    var getRSSChannelsError: Error?
    func getRSSChannels() async throws {
        getRSSChannelsCalls += 1
        if let getRSSChannelsError {
            throw getRSSChannelsError
        }
        if let channelsToEmit {
            subject.send(channelsToEmit)
        }
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
