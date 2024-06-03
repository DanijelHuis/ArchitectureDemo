//
//  DefaultRSSHistoryRepositoryTests.swift
//
//
//  Created by Danijel Huis on 20.05.2024..
//

import XCTest
import TestUtility
import Domain
@testable import Data

final class DefaultRSSHistoryRepositoryTests: XCTestCase {
    private var persistenceManager: MockPersistenceManager!
    private var sut: DefaultRSSHistoryRepository!
    
    private struct Mock {
        static let loadError = MockError.generalError("load error 505")
        static let saveError = MockError.generalError("save error 505")
        static let uuid1 = UUID()
        static let uuid2 = UUID()
        static let uuid3 = UUID()
        static let uuid4 = UUID()
        static let nonExistingUUID = UUID()
        static let item1 = RSSHistoryItem.mock(id: uuid1, channelURL: URL(string: "https://item1")!)
        static let item2 = RSSHistoryItem.mock(id: uuid2, channelURL: URL(string: "https://item2")!)
        static let item3 = RSSHistoryItem.mock(id: uuid3, channelURL: URL(string: "https://item3")!)
        static let newItem = RSSHistoryItem.mock(id: uuid3, channelURL: URL(string: "https://newitem")!)
        static let newItemWithSameURL = RSSHistoryItem.mock(id: uuid4, channelURL: URL(string: "https://item1")!)
        static let items = [item1, item2, item3]
    }
    
    override func setUp() {
        persistenceManager = .init()
        sut = .init(persistenceManager: persistenceManager)
    }
    
    override func tearDown() {
        persistenceManager = nil
        sut = nil
    }
    
    // MARK: - getRSSHistoryItems -
    
    func test_getRSSHistoryItems_givenSuccess_thenReturnsItems() throws {
        // Given
        persistenceManager.loadCallsResult = .success(Mock.items)
        // When
        let items = try sut.getRSSHistoryItems()
        // Then: returns items
        XCTAssertEqual(items, Mock.items)
        // Then: does request coorect key and type
        XCTAssertEqual(persistenceManager.loadCalls.count, 1)
        XCTAssertEqual(persistenceManager.loadCalls.first?.key, "RSSHistoryRepository.channelsPersistenceKey")
        XCTAssertNotNil(persistenceManager.loadCalls.first?.type as? [RSSHistoryItem].Type)
    }
    
    func test_getRSSHistoryItems_givenFailure_thenThrows() throws {
        // Given
        persistenceManager.loadCallsResult = .failure(Mock.loadError)
        // Then
        XCTAssertThrowsError(try sut.getRSSHistoryItems()) {
            XCTAssertEqual($0 as? MockError, Mock.loadError)
        }
    }
    
    // MARK: - getRSSHistoryItem -
    
    func test_getRSSHistoryItem_givenSuccess_givenExistingID_thenReturnsItem() throws {
        // Given
        persistenceManager.loadCallsResult = .success(Mock.items)
        // When
        let item = try sut.getRSSHistoryItem(id: Mock.uuid1)
        // Then
        XCTAssertEqual(persistenceManager.loadCalls.count, 1)
        XCTAssertEqual(item, Mock.items.first)
    }
    
    func test_getRSSHistoryItem_givenSuccess_givenNonExistingID_thenThrowsError() throws {
        // Given
        persistenceManager.loadCallsResult = .success(Mock.items)
        // Then
        XCTAssertThrowsError(try sut.getRSSHistoryItem(id: Mock.nonExistingUUID)) {
            XCTAssertEqual($0 as? RSSHistoryRepositoryError, .historyItemNotFound)
        }
    }
    
    func test_getRSSHistoryItem_givenFailure_thenThrowsError() throws {
        // Given
        persistenceManager.loadCallsResult = .failure(Mock.loadError)
        // Then
        XCTAssertThrowsError(try sut.getRSSHistoryItem(id: Mock.nonExistingUUID)) {
            XCTAssertEqual($0 as? MockError, Mock.loadError)
        }
    }
    
    // MARK: - addRSSHistoryItem -
    
    func test_addRSSHistoryItem_givenSuccess_thenAddsItemAtTheEnd() throws {
        // Given
        persistenceManager.loadCallsResult = .success(Mock.items)
        // When
        let items = try sut.addRSSHistoryItem(Mock.newItem)
        // Then
        XCTAssertEqual(items, Mock.items + [Mock.newItem])
        XCTAssertEqual(persistenceManager.loadCalls.count, 1)
        XCTAssertEqual(persistenceManager.saveCalls.count, 1)
    }
    
    func test_addRSSHistoryItem_givenLoadFailure_thenThrowsError() throws {
        // Given
        persistenceManager.loadCallsResult = .failure(Mock.loadError)
        // Then
        XCTAssertThrowsError(try sut.addRSSHistoryItem(Mock.newItem)) {
            XCTAssertEqual($0 as? MockError, Mock.loadError)
        }
    }
    
    func test_addRSSHistoryItem_givenSaveFailure_thenThrowsError() throws {
        // Given
        persistenceManager.loadCallsResult = .success(Mock.items)
        persistenceManager.saveError = Mock.saveError
        // Then
        XCTAssertThrowsError(try sut.addRSSHistoryItem(Mock.newItem)) {
            XCTAssertEqual($0 as? MockError, Mock.saveError)
        }
    }
    
    func test_addRSSHistoryItem_givenItemWithSameURL_thenThrowsError() throws {
        // Given
        persistenceManager.loadCallsResult = .success(Mock.items)
        persistenceManager.saveError = nil
        // Then
        XCTAssertThrowsError(try sut.addRSSHistoryItem(Mock.newItemWithSameURL)) {
            XCTAssertEqual($0 as? RSSHistoryRepositoryError, .urlAlreadyExists)
        }
    }
    
    // MARK: - removeRSSHistoryItem -
    
    func test_removeRSSHistoryItem_givenSuccess_thenAddsItemAtTheEnd() throws {
        // Given
        persistenceManager.loadCallsResult = .success(Mock.items)
        // When
        let items = try sut.removeRSSHistoryItem(historyItemID: Mock.uuid2)
        // Then
        XCTAssertEqual(items, [Mock.item1, Mock.item3])
        XCTAssertEqual(persistenceManager.loadCalls.count, 1)
        XCTAssertEqual(persistenceManager.saveCalls.count, 1)
    }
    
    
    func test_removeRSSHistoryItem_givenLoadFailure_thenThrowsError() throws {
        // Given
        persistenceManager.loadCallsResult = .failure(Mock.loadError)
        // Then
        XCTAssertThrowsError(try sut.removeRSSHistoryItem(historyItemID: Mock.uuid1)) {
            XCTAssertEqual($0 as? MockError, Mock.loadError)
        }
    }
    
    func test_removeRSSHistoryItem_givenSaveFailure_thenThrowsError() throws {
        // Given
        persistenceManager.loadCallsResult = .success(Mock.items)
        persistenceManager.saveError = Mock.saveError
        // Then
        XCTAssertThrowsError(try sut.removeRSSHistoryItem(historyItemID: Mock.uuid1)) {
            XCTAssertEqual($0 as? MockError, Mock.saveError)
        }
    }
    
    // MARK: - updateRSSHistoryItem -
    
    func test_updateRSSHistoryItem_givenSuccess_thenAddsItemAtTheEnd() throws {
        // Given
        var allItems = Mock.items + [Mock.newItem]
        persistenceManager.loadCallsResult = .success(Mock.items)
        let modifiedItem = RSSHistoryItem(id: Mock.uuid2, channelURL: URL(string: "https://new")!, isFavourite: true)
        // When: replacing item 2
        let items = try sut.updateRSSHistoryItem(modifiedItem)
        // Then
        XCTAssertEqual(items, [Mock.item1, modifiedItem, Mock.item3])
    }
    
    func test_updateRSSHistoryItem_givenLoadFailure_thenThrowsError() throws {
        // Given
        persistenceManager.loadCallsResult = .failure(Mock.loadError)
        let modifiedItem = RSSHistoryItem(id: Mock.uuid2, channelURL: URL(string: "https://new")!, isFavourite: true)
        // Then
        XCTAssertThrowsError(try sut.updateRSSHistoryItem(modifiedItem)) {
            XCTAssertEqual($0 as? MockError, Mock.loadError)
        }
    }
    
    func test_updateRSSHistoryItem_givenSaveFailure_thenThrowsError() throws {
        // Given
        persistenceManager.loadCallsResult = .success(Mock.items)
        persistenceManager.saveError = Mock.saveError
        let modifiedItem = RSSHistoryItem(id: Mock.uuid2, channelURL: URL(string: "https://new")!, isFavourite: true)
        // Then
        XCTAssertThrowsError(try sut.updateRSSHistoryItem(modifiedItem)) {
            XCTAssertEqual($0 as? MockError, Mock.saveError)
        }
    }
}

private final class MockPersistenceManager: PersistenceManager {
    var saveCalls = [(object: Any, key: String)]()
    var saveError: Error?
    func save<T>(_ object: T, forKey: String) throws where T : Encodable {
        saveCalls.append((object, forKey))
        if let saveError {
            throw saveError
        }
    }
    
    var loadCalls = [(key: String, type: Any)]()
    var loadCallsResult: Result<Any, Error> = .failure(MockError.mockNotSetup)
    func load<T>(key: String, type: T.Type) throws -> T? where T : Decodable {
        loadCalls.append((key: key, type: type))
        return try loadCallsResult.get() as? T
    }
}
