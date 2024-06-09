//
//  String+LocalizationTests.swift
//
//
//  Created by Danijel Huis on 06.05.2024..
//

import XCTest
@testable import CommonUI

final class StringLocalizationTests: XCTestCase {
    
    // MARK: - localized -
    
    func test_localized_givenValidKey_thenReturnsLocalization() {
        XCTAssertEqual("test_key".localized, "Test value")
    }
    
    func test_localized_givenInvalidKey_thenReturnsKey() {
        XCTAssertEqual("invalid key".localized, "invalid key")
    }
    
    // MARK: - localized with default value -
    
    func test_localizedWithDefaultValue_givenValidKey_thenReturnsLocalization() {
        XCTAssertEqual("test_key".localized(default: "Default 1"), "Test value")
    }
    
    func test_localizedWithDefaultValue_givenInvalidKey_thenReturnsDefaultValue() {
        XCTAssertEqual("invalid key".localized(default: "Default 1"), "Default 1")
    }
}
