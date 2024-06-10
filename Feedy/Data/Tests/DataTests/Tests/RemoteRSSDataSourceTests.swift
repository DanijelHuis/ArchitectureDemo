//
//  RemoteRSSDataSourceTests.swift
//
//
//  Created by Danijel Huis on 19.05.2024..
//

import XCTest
@testable import Data

final class RemoteRSSDataSourceTests: XCTestCase {
    private var httpClient: MockHTTPClient!
    private var sut: RemoteRSSDataSource!
    
    private struct Mock {
        static let url = URL(string: "https://test1")!
        static let response = RemoteRSSChannelResponse(
            channel: .init(title: "channel title",
                           description: "channel description",
                           image: .init(url: URL(string: "https://channel1")),
                           item: [.init(guid: "item guid 1",
                                        title: "item title 1",
                                        description: "item description 1",
                                        link: .init(string: "https://link1"),
                                        enclosure: .init(url: URL(string: "https://enclosure1")!, type: "image/jpg"),
                                        pubDate: "Tue, 21 May 2024 09:10:11 +0200"),
                                  .init(guid: "item guid 2",
                                        title: "item title 2",
                                        description: "item description 2",
                                        link: .init(string: "https://link2"),
                                        enclosure: .init(url: URL(string: "https://enclosure2")!, type: "video/jpg"),
                                        pubDate: "Tue, 22 May 2024 10:11:12 +0200")
                           ])
        )
    }
    
    override func setUp() {
        httpClient = .init()
        sut = .init(httpClient: httpClient)
    }
    
    override func tearDown() {
        httpClient = nil
        sut = nil
    }
    
    func test_getRSSChannel_thenSetsRequestCorrectly() async throws {
        // Given
        httpClient.setup(buildRequest: true, authorizeRequest: true, response: Mock.response)
        // When
        _ = try await sut.getRSSChannel(url: Mock.url)
        // Then
        XCTAssertEqual(httpClient.buildRequestCalls.count, 1)
        XCTAssertEqual(httpClient.buildRequestCalls.first?.url, Mock.url)
        XCTAssertEqual(httpClient.buildRequestCalls.first?.method, .get)
        XCTAssertEqual(httpClient.buildRequestCalls.first?.headers, nil)
        XCTAssertEqual(httpClient.buildRequestCalls.first?.body, nil)
        XCTAssertEqual(httpClient.buildRequestCalls.first?.query, nil)
    }
    
    func test_getRSSChannel_thenMapsCorrectly() async throws {
        let formatter = ISO8601DateFormatter()

        // Given
        httpClient.setup(buildRequest: true, authorizeRequest: true, response: Mock.response)
        
        // When
        let channel = try await sut.getRSSChannel(url: Mock.url)
        
        // Then: maps remote to domain object correctly
        XCTAssertEqual(channel.title, "channel title")
        XCTAssertEqual(channel.description, "channel description")
        XCTAssertEqual(channel.imageURL, URL(string: "https://channel1"))
        XCTAssertEqual(channel.items.count, 2)
        
        // Then: items are sorted (notice the reverse order of items) and mapped
        let item1 = try XCTUnwrap(channel.items.first)
        let item2 = try XCTUnwrap(channel.items.last)

        XCTAssertEqual(item1.guid, "item guid 2")
        XCTAssertEqual(item1.title, "item title 2")
        XCTAssertEqual(item1.description, "item description 2")
        XCTAssertEqual(item1.link, URL(string: "https://link2")!)
        // Then: it doesn't set url if type is not image.
        XCTAssertEqual(item1.imageURL, nil)
        XCTAssertEqual(item1.pubDate, formatter.date(from: "2024-05-22T08:11:12+00:00"))
        
        XCTAssertEqual(item2.guid, "item guid 1")
        XCTAssertEqual(item2.title, "item title 1")
        XCTAssertEqual(item2.description, "item description 1")
        XCTAssertEqual(item2.link, URL(string: "https://link1")!)
        XCTAssertEqual(item2.imageURL, URL(string: "https://enclosure1")!)
        XCTAssertEqual(item2.pubDate, formatter.date(from: "2024-05-21T07:10:11+00:00"))
    }
    
    // This will test some standard test, e.g. when build request fails, when perform request fails etc.
    func test_getRSSChannel_runStandardTests() async throws {
        // Given
        httpClient.setup(buildRequest: true, authorizeRequest: true, response: Mock.response)
        // Then
        await httpClient.runStandardTests(testCase: self, checkAuthorization: false) {
            // When
            try await sut.getRSSChannel(url: Mock.url)
        }
    }
}

