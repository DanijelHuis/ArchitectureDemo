//
//  PokemonHeightFormatterTests.swift
//
//
//  Created by Danijel Huis on 06.05.2024..
//

import XCTest
@testable import Presentation

final class PokemonHeightFormatterTests: XCTestCase {
    private var sut: PokemonHeightFormatter!
    
    override func setUp() {
        sut = .init(locale: .init(identifier: "en_GB"))
    }
    
    override func tearDown() {
        sut = nil
    }
    
    func test_string_givenRangeOfValues_thenFormatsCorrectly() {
        XCTAssertEqual(sut.string(from: 0), "0.00 cm")
        XCTAssertEqual(sut.string(from: 1), "10.00 cm")
        XCTAssertEqual(sut.string(from: 15), "150.00 cm")
        XCTAssertEqual(sut.string(from: 598), "5,980.00 cm")
        XCTAssertEqual(sut.string(from: 1491), "14,910.00 cm")
        XCTAssertEqual(sut.string(from: 150_320), "1,503,200.00 cm")
        
        XCTAssertEqual(sut.string(from: -500), "-5,000.00 cm")
    }
}
