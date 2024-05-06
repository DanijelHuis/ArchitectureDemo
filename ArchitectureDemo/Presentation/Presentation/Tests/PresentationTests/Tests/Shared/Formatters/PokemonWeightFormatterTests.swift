//
//  PokemonWeightFormatterTests.swift
//
//
//  Created by Danijel Huis on 06.05.2024..
//

import XCTest
@testable import Presentation

final class PokemonWeightFormatterTests: XCTestCase {
    private var sut: PokemonWeightFormatter!
    
    override func setUp() {
        sut = .init(locale: .init(identifier: "en_GB"))
    }
    
    override func tearDown() {
        sut = nil
    }
    
    func test_string_givenRangeOfValues_thenFormatsCorrectly() {
        XCTAssertEqual(sut.string(from: 0), "0.00 kg")
        XCTAssertEqual(sut.string(from: 1), "0.10 kg")
        XCTAssertEqual(sut.string(from: 15), "1.50 kg")
        XCTAssertEqual(sut.string(from: 598), "59.80 kg")
        XCTAssertEqual(sut.string(from: 1491), "149.10 kg")
        XCTAssertEqual(sut.string(from: 150_320), "15,032.00 kg")
        
        XCTAssertEqual(sut.string(from: -500), "-50.00 kg")
    }
}
