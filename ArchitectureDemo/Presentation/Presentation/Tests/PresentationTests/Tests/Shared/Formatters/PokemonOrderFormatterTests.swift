//
//  PokemonOrderFormatterTests.swift
//
//
//  Created by Danijel Huis on 06.05.2024..
//

import XCTest
@testable import Presentation

final class PokemonOrderFormatterTests: XCTestCase {
    private var sut: PokemonOrderFormatter!
    
    override func setUp() {
        sut = .init(locale: .init(identifier: "en_GB"))
    }
    
    override func tearDown() {
        sut = nil
    }
    
    func test_string_givenRangeOfValues_thenFormatsCorrectly() {
        XCTAssertEqual(sut.string(from: 0), "#000")
        XCTAssertEqual(sut.string(from: 1), "#001")
        XCTAssertEqual(sut.string(from: 15), "#015")
        XCTAssertEqual(sut.string(from: 598), "#598")
        XCTAssertEqual(sut.string(from: 1491), "#1,491")
        XCTAssertEqual(sut.string(from: 150_320), "#150,320")
        
        XCTAssertEqual(sut.string(from: -500), "#-500")
    }
}
