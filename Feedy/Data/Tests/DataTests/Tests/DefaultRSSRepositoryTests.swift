//
//  DefaultRSSRepositoryTests.swift
//
//
//  Created by Danijel Huis on 20.05.2024..
//

import XCTest
import TestUtility
import Domain
@testable import Data

final class DefaultRSSRepositoryTests: XCTestCase {
    private var dataSource: MockRSSDataSource!
    private var sut: DefaultRSSRepository!
    
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
        dataSource = .init()
        sut = .init(remoteDataSource: dataSource)
    }
    
    @UnitTestActor override func tearDown() {
        dataSource = nil
        sut = nil
    }
    
    @UnitTestActor func test_getRSSChannel_givenSuccess_thenReturnsObject() async throws {
        // Given
        dataSource.getRSSChannelResult = .success(Mock.channel1)
        // When
        let channel = try await sut.getRSSChannel(url: Mock.url1)
        // Then
        XCTAssertEqual(channel, Mock.channel1)
    }
    
    @UnitTestActor func test_getRSSChannel_givenFailure_thenThrows() async throws {
        // Given
        dataSource.getRSSChannelResult = .failure(Mock.loadError)
        // Then
        await XCTAssertError(Mock.loadError) {
            // When
            try await sut.getRSSChannel(url: Mock.url1)
        }
    }
    
    @UnitTestActor func test_getRSSChannels_givenSuccessAndFailures_thenFetchesAndReturnsAllChannels() async throws {
        // Given
        dataSource.getRSSChannelResultPerURL = Mock.response
        // When
        let items = await sut.getRSSChannels(historyItems: Mock.items)
        // Then: check that channels are fetched exactly 3 times and with correct urls, order in TaskGroup cannot be guaranteed so it doesn't matter.
        XCTAssertEqual(dataSource.getRSSChannelCalls.map { $0.absoluteString }.sorted(by: <),
                       [Mock.url1.absoluteString, Mock.url2.absoluteString, Mock.url3.absoluteString])
        
        // Then: Returns correct items
        XCTAssertEqual(items.count, 3)
        XCTAssertEqual(items[Mock.uuid1]?.success, Mock.channel1)
        XCTAssertEqual(items[Mock.uuid2]?.failure as? RSSChannelError, .failedToLoad)
        XCTAssertEqual(items[Mock.uuid3]?.success, Mock.channel3)
    }
}

@UnitTestActor
private final class MockRSSDataSource: RSSDataSource {
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
