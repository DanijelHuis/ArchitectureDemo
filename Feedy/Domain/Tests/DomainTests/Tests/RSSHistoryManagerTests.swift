//
//  RSSHistoryManagerTests.swift
//
//
//  Created by Danijel Huis on 20.05.2024..
//

import XCTest
import Combine
import TestUtility
@testable import Domain

final class RSSHistoryManagerTests: XCTestCase {
    private var repository: MockRSSHistoryRepository!
    private var sut: RSSHistoryManager!
    
    private var events = [RSSHistoryEvent]()
    private var cancellables: Set<AnyCancellable> = []
    
    private struct Mock {
        static let error = MockError.generalError("error 1")
        static let url = URL(string: "https://url1")!
        static let item1 = RSSHistoryItem.mock()
        static let item2 = RSSHistoryItem.mock()
        static let item3 = RSSHistoryItem.mock()
        static let items = [item1, item2, item3]
    }
    
    override func setUp() {
        repository = .init()
        sut = .init(repository: repository)
        
        sut.output.sink { [weak self] event in
            self?.events.append(event)
        }.store(in: &cancellables)
    }
    
    override func tearDown() {
        repository = nil
        sut = nil
    }
    
    // MARK: - getRSSHistoryItems -
    
    func test_getRSSHistoryItems_givenSuccess_thenSendsUpdateEventWithCorrectItems() throws {
        // Given
        repository.getRSSHistoryItemsResult = .success(Mock.items)
        // When
        try sut.getRSSHistoryItems()
        // Then
        XCTAssertEqual(events, [.init(reason: .update, historyItems: Mock.items)])
    }
    
    func test_getRSSHistoryItems_givenFailure_thenThrows() throws {
        // Given
        repository.getRSSHistoryItemsResult = .failure(Mock.error)
        // When
        XCTAssertThrowsError(try sut.getRSSHistoryItems()) { error in
            XCTAssertEqual(error as? MockError, Mock.error)
        }
        XCTAssertEqual(events, [])
    }
    
    // MARK: - addRSSHistoryItem -
    
    func test_addRSSHistoryItem_givenSuccess_thenAddsItemAndSendsAddEvent() throws {
        // Given
        repository.addRSSHistoryItemResult = .success(Mock.items)
        // When
        try sut.addRSSHistoryItem(channelURL: Mock.url)
        // Then: sends correct parameters to repository
        XCTAssertEqual(repository.addRSSHistoryItemCalls.count, 1)
        XCTAssertEqual(repository.addRSSHistoryItemCalls.first?.channelURL, Mock.url)
        let addedID = try XCTUnwrap(repository.addRSSHistoryItemCalls.first?.id)
        // Then: outputs correct event
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events, [.init(reason: .add(historyItemID: addedID), historyItems: Mock.items)])
    }
    
    func test_addRSSHistoryItem_givenFailure_thenThrows() throws {
        // Given
        repository.addRSSHistoryItemResult = .failure(Mock.error)
        // When
        XCTAssertThrowsError(try sut.addRSSHistoryItem(channelURL: Mock.url)) { error in
            XCTAssertEqual(error as? MockError, Mock.error)
        }
        XCTAssertEqual(events, [])
    }
    
    // MARK: - removeRSSHistoryItem -
    
    func test_removeRSSHistoryItem_givenSuccess_thenRemovesItemAndSendsRemoveEvent() throws {
        // Given
        let uuid = UUID()
        repository.removeRSSHistoryItemResult = .success(Mock.items)
        // When
        try sut.removeRSSHistoryItem(uuid)
        // Then
        XCTAssertEqual(events, [.init(reason: .remove(historyItemID: uuid), historyItems: Mock.items)])
    }
    
    func test_removeRSSHistoryItem_givenFailure_thenThrows() throws {
        // Given
        let uuid = UUID()
        repository.removeRSSHistoryItemResult = .failure(Mock.error)
        // When
        XCTAssertThrowsError(try sut.removeRSSHistoryItem(uuid)) { error in
            XCTAssertEqual(error as? MockError, Mock.error)
        }
        XCTAssertEqual(events, [])
    }
    
    // MARK: - changeFavouriteStatus -
    
    func test_changeFavouriteStatus_givenSuccess_thenSendsUpdateEventWithCorrectItems() throws {
        // Given
        let item = Mock.item2
        repository.getRSSHistoryItemResult = .success(item)
        repository.updateRSSHistoryItemResult = .success(Mock.items)
        // When
        try sut.changeFavouriteStatus(historyItemID: item.id, isFavourite: true)
        // Then: request correct item
        XCTAssertEqual(repository.getRSSHistoryItemCalls.count, 1)
        XCTAssertEqual(repository.getRSSHistoryItemCalls.first, item.id)
        // Then: updates correct item and sets favourite
        XCTAssertEqual(repository.updateRSSHistoryItemCalls.count, 1)
        XCTAssertEqual(repository.updateRSSHistoryItemCalls.first?.id, item.id)
        XCTAssertEqual(repository.updateRSSHistoryItemCalls.first?.isFavourite, true)
        // Then: sends correct event
        XCTAssertEqual(events, [.init(reason: .favouriteStatusUpdated(historyItemID: item.id), historyItems: Mock.items)])
    }
    
    func test_changeFavouriteStatus_givenGetRSSHistoryItemFailure_thenThrows() throws {
        // Given
        let item = Mock.item2
        repository.getRSSHistoryItemResult = .failure(Mock.error)
        repository.updateRSSHistoryItemResult = .success(Mock.items)
        // When
        XCTAssertThrowsError(try sut.changeFavouriteStatus(historyItemID: item.id, isFavourite: true)) { error in
            XCTAssertEqual(error as? MockError, Mock.error)
        }
        XCTAssertEqual(events, [])
    }
    
    func test_changeFavouriteStatus_givenUpdateRSSHistoryItemFailure_thenThrows() throws {
        // Given
        let item = Mock.item2
        repository.getRSSHistoryItemResult = .success(item)
        repository.updateRSSHistoryItemResult = .failure(Mock.error)
        // When
        XCTAssertThrowsError(try sut.changeFavouriteStatus(historyItemID: item.id, isFavourite: true)) { error in
            XCTAssertEqual(error as? MockError, Mock.error)
        }
        XCTAssertEqual(events, [])
    }
}
