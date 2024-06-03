//
//  FilRSSChannelItemListCellStateMapperTestse.swift
//
//
//  Created by Danijel Huis on 21.05.2024..
//

import XCTest
import Domain
@testable import Presentation

final class RSSChannelItemListCellStateMapperTests: XCTestCase {
    private var sut: RSSChannelItemListCellStateMapper!
    
    private struct Mock {
        static let item1 = RSSItem.mock(guid: "1", title: "title1",
                                        description: "description1",
                                        link: URL(string: "link1"),
                                        imageURL: URL(string: "image1"),
                                        pubDate: Date(timeIntervalSince1970: 0))
        static let item2 = RSSItem.mock(guid: "2", title: "title2",
                                        description: "description2",
                                        link: URL(string: "link2"),
                                        imageURL: URL(string: "image2"),
                                        pubDate: Date(timeIntervalSince1970: 24 * 60 * 60))
    }
    override func setUp() {
        sut = .init(locale: Locale(identifier: "en"), timeZone: TimeZone(secondsFromGMT: 0)!)
    }
    
    override func tearDown() {
        sut = nil
    }
    
    func test_map() {
        // When
        let items = sut.map(rssItems: [Mock.item1, Mock.item2])
        // Then
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items.first?.id, "1")
        XCTAssertEqual(items.first?.title, "title1")
        XCTAssertEqual(items.first?.description, "description1")
        XCTAssertEqual(items.first?.imageURL?.absoluteString, "image1")
        XCTAssertEqual(items.first?.link?.absoluteString, "link1")
        XCTAssertEqual(items.first?.publishDate, "January 1, 1970 at 12:00 AM")
        
        XCTAssertEqual(items.last?.id, "2")
        XCTAssertEqual(items.last?.title, "title2")
        XCTAssertEqual(items.last?.description, "description2")
        XCTAssertEqual(items.last?.imageURL?.absoluteString, "image2")
        XCTAssertEqual(items.last?.link?.absoluteString, "link2")
        XCTAssertEqual(items.last?.publishDate, "January 2, 1970 at 12:00 AM")

    }
}

