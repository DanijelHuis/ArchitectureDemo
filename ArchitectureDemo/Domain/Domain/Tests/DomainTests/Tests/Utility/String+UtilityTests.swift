//
//  String+UtilityTests.swift
//
//
//  Created by Danijel Huis on 06.05.2024..
//

import XCTest
@testable import Domain

final class StringUtilityTests: XCTestCase {
    
    func test_replacingVariable_givenCorrectVariableKey_thenReplacesVariableCorrectly() {
        XCTAssertEqual("A {{var1}} b".replacingVariable("var1", with: "Dog"), "A Dog b" )
    }
    
    func test_replacingVariable_givenInvalidCaseForVariableKey_thenReplacesVariableCorrectly() {
        XCTAssertEqual("A {{var1}} b".replacingVariable("VAr1", with: "Dog"), "A Dog b" )
    }
    
    func test_replacingVariable_givenIncorrectVariableKey_thenDoesntReplaceVariable() {
        XCTAssertEqual("A {{var1}} b".replacingVariable("va", with: "Dog"), "A {{var1}} b" )
    }
    
    func test_replacingVariable_givenNoVariable_thenDoesNothing() {
        XCTAssertEqual("A b".replacingVariable("var1", with: "Dog"), "A b" )
    }
}
