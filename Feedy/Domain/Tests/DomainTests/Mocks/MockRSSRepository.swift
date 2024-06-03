//
//  MockRSSRepository.swift
//  
//
//  Created by Danijel Huis on 20.05.2024..
//

import Foundation
import Domain
import TestUtility

@UnitTestActor final class MockRSSRepository: RSSRepository {
    var getRSSChannelCalls = [URL]()
    var getRSSChannelResultPerURL = [URL: Result<RSSChannel, Error>]()
    var getRSSChannelResult: Result<RSSChannel, Error> = .failure(MockError.mockNotSetup)

    func getRSSChannel(url: URL) async throws -> Domain.RSSChannel {
        getRSSChannelCalls.append(url)
        if let result = getRSSChannelResultPerURL[url] {
            return try result.get()
        }
        return try getRSSChannelResult.get()
    }
}
