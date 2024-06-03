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
        static let error = MockError.generalError("error 1")
        static let url = URL(string: "https://test1")!
        static let channel = RSSChannel(title: "channel title",
                                        description: "channel description",
                                        imageURL: URL(string: "https://channel1"),
                                        items: [.init(guid: "item guid 1",
                                                      title: "item title 1",
                                                      description: "item description 1",
                                                      link: .init(string: "https://link1"),
                                                      imageURL: URL(string: "https://enclosure1")!, 
                                                      pubDate: Date(timeIntervalSince1970: 0))])
        
    }
    
    
    override func setUp() {
        dataSource = .init()
        sut = .init(remoteDataSource: dataSource)
    }
    
    override func tearDown() {
        dataSource = nil
        sut = nil
    }
    
    func test_getRSSChannel_givenSuccess_thenReturnsObject() async throws {
        // Given
        dataSource.getRSSChannelResult = .success(Mock.channel)
        // When
        let channel = try await sut.getRSSChannel(url: Mock.url)
        // Then
        XCTAssertEqual(channel, Mock.channel)
    }
    
    func test_getRSSChannel_givenFailure_thenThrows() async throws {
        // Given
        dataSource.getRSSChannelResult = .failure(Mock.error)
        // Then
        await XCTAssertError(Mock.error) {
            // When
            try await sut.getRSSChannel(url: Mock.url)
        }
    }
}

private final class MockRSSDataSource: RSSDataSource {
    var getRSSChannelCalls = [URL]()
    var getRSSChannelResult: Result<RSSChannel, Error> = .failure(MockError.mockNotSetup)
    func getRSSChannel(url: URL) async throws -> Domain.RSSChannel {
        getRSSChannelCalls.append(url)
        return try getRSSChannelResult.get()
    }
}
