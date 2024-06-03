//
//  DefaultGetRSSChannelsUseCaseTests.swift
//
//
//  Created by Danijel Huis on 20.05.2024..
//

import XCTest
import TestUtility
@testable import Domain

final class DefaultGetRSSChannelsUseCaseTests: XCTestCase {
    private var repository: MockRSSRepository!
    private var sut: DefaultGetRSSChannelsUseCase!
    
    private struct Mock {
        static let loadError = MockError.generalError("load error 505")
        static let saveError = MockError.generalError("save error 505")
        static let uuid1 = UUID()
        static let uuid2 = UUID()
        static let uuid3 = UUID()
        static let url1 = URL(string: "https://channel1")!
        static let url2 = URL(string: "https://channel2")!
        static let url3 = URL(string: "https://channel3")!

        static let item1 = RSSHistoryItem.mock(id: uuid1, channelURL: url1)
        static let item2 = RSSHistoryItem.mock(id: uuid2, channelURL: url2)
        static let item3 = RSSHistoryItem.mock(id: uuid3, channelURL: url3)
        static let items = [item1, item2, item3]
        
        static let channel1 = RSSChannel.mock()
        static let channel2Error = MockError.generalError("channel 2 error")
        static let channel3 = RSSChannel.mock()
        static let response: [URL: Result<RSSChannel, Error>] = [
            url1: .success(channel1),
            url2: .failure(channel2Error),
            url3: .success(channel3)
            ]
    }
    
    @UnitTestActor override func setUp() {
        repository = .init()
        sut = .init(repository: repository)
    }
    
    @UnitTestActor override func tearDown() {
        repository = nil
        sut = nil
    }
    
    @UnitTestActor func test_getRSSChannels_givenSuccessAndFailures_thenFetchesAndReturnsAllChannels() async throws {
        // Given
        repository.getRSSChannelResultPerURL = Mock.response
        // When
        let items = await sut.getRSSChannels(historyItems: Mock.items)
        // Then: check that channels are fetched exactly 3 times and with correct urls, order in TaskGroup cannot be guaranteed so it doesn't matter.
        XCTAssertEqual(repository.getRSSChannelCalls.map { $0.absoluteString }.sorted(by: <),
                       [Mock.url1.absoluteString, Mock.url2.absoluteString, Mock.url3.absoluteString])

        // Then: Returns correct items
        XCTAssertEqual(items.count, 3)
        XCTAssertEqual(items[Mock.uuid1]?.success, Mock.channel1)
        XCTAssertEqual(items[Mock.uuid2]?.failure as? RSSChannelError, .failedToLoad)
        XCTAssertEqual(items[Mock.uuid3]?.success, Mock.channel3)
    }
}
