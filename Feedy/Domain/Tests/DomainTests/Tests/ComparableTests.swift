//
//  ComparableTests.swift
//
//
//  Created by Danijel Huis on 21.05.2024..
//

import XCTest
@testable import Domain

final class ComparableTests: XCTestCase {
    
    func test_ascendingSort_thenSortsAscendingAndPutsNilAtTheEnd() {
        var items = ["1", "9", nil, "5", nil, "2"]
        XCTAssertEqual(items.sorted(by: <<<), ["1", "2", "5", "9", nil, nil])
    }
    
    func test_descendingSort_thenSortsAscendingAndPutsNilAtTheEnd() {
        var items = ["1", "9", nil, "5", nil, "2"]
        XCTAssertEqual(items.sorted(by: >>>), ["9", "5", "2", "1", nil, nil])
    }
}
