//
//  PaginationManagerTests.swift
//
//
//  Created by Danijel Huis on 05.05.2024..
//

import Foundation
import XCTest
@testable import Domain

final class PaginationManagerTests: XCTestCase {
    private var sut: PaginationManager!
    private let pageSize = 10
    
    override func setUp() {
        sut = .init(pageSize: pageSize)
    }
    
    override func tearDown() {
        sut = nil
    }

    // MARK: - initial state -
    
    func test_totalItemCount_whenCalledBeforeAnyAddedPage_thenReturnsNil() {
        XCTAssertEqual(sut.totalItemCount, nil)
    }
    
    func test_firstPage_thenReturnsCorrectOffsetAndLimit() {
        XCTAssertEqual(sut.firstPage, .init(offset: 0, limit: pageSize))
    }
    
    func test_nextPage_whenCalledBeforeAnyAddedPage_thenReturnsNil() {
        XCTAssertEqual(sut.nextPage, nil)
    }
    
    // MARK: - addPage -
    
    func test_addPage_givenMoreItemsOnBackend_thenTotalItemCountReturnsCorrectValue_thenNextPageReturnsCorrectValue() {
        // When
        sut.addPage(.init(offset: 0, limit: pageSize), totalItemCount: 50)
        sut.addPage(.init(offset: 10, limit: pageSize), totalItemCount: 50)

        // Then
        XCTAssertEqual(sut.nextPage, .init(offset: 20, limit: 10))
        XCTAssertEqual(sut.totalItemCount, 50)
    }
    
    func test_addPage_givenCalledUntilThereAreNoMoreItems_thenTotalItemCountReturnsCorrectValue_thenNextPageReturnsCorrectValue() {
        // When
        sut.addPage(.init(offset: 0, limit: pageSize), totalItemCount: 20)
        // Then
        XCTAssertEqual(sut.nextPage, .init(offset: 10, limit: 10))
        XCTAssertEqual(sut.totalItemCount, 20)
        
        // When
        sut.addPage(.init(offset: 10, limit: pageSize), totalItemCount: 20)
        // Then
        XCTAssertEqual(sut.nextPage, nil)
        XCTAssertEqual(sut.totalItemCount, 20)
    }
    
    func test_addPage_givenZeroOffset_givenPagesAddedBefore_thenRemovesExistingPages() {
        // Given
        sut.addPage(.init(offset: 0, limit: pageSize), totalItemCount: 50)
        sut.addPage(.init(offset: 10, limit: pageSize), totalItemCount: 50)
        sut.addPage(.init(offset: 30, limit: pageSize), totalItemCount: 50)

        // When: added page with offset 0 when pages exist should remove all existing pages
        sut.addPage(.init(offset: 0, limit: 10), totalItemCount: 20)

        // Then: nextPage is second page, which means it did reset previous pages
        XCTAssertEqual(sut.nextPage, .init(offset: 10, limit: 10))
    }
    
    // MARK: - removeAllPages -
    
    func test_removeAllPages_givenPagesAddedBefore_thenRemovesExistingPagesAndResetsTotalCount() {
        // Given
        sut.addPage(.init(offset: 0, limit: pageSize), totalItemCount: 50)
        sut.addPage(.init(offset: 10, limit: pageSize), totalItemCount: 50)
        sut.addPage(.init(offset: 30, limit: pageSize), totalItemCount: 50)
        
        // When: added page with offset 0 when pages exist
        sut.removeAllPages()
        
        // Then: nextPage is nil
        XCTAssertEqual(sut.nextPage, nil)
        XCTAssertEqual(sut.totalItemCount, nil)
    }
}
