//
//  UserDefaultsPersistenceManagerTests.swift
//
//
//  Created by Danijel Huis on 19.05.2024..
//

import XCTest
@testable import Data

final class UserDefaultsPersistenceManagerTests: XCTestCase {
    private var userDefaults: MockUserDefaults!
    private var sut: UserDefaultsPersistenceManager!
    
    private struct Mock {
        static let testObject = TestObject(text: "text 1")
        // This cannot be saved to json and will make encoder fail.
        static let testObject2 = TestObject2(number: Double.infinity)
    }
    
    override func setUp() {
        userDefaults = .init()
        sut = .init(userDefaults: userDefaults)
    }
    
    override func tearDown() {
        userDefaults = nil
        sut = nil
    }
    
    func test_saveAndLoad_givenValidEncodableObject_thenSavesToUserDefaults_thenObjectIsCorrectlyEncodedAndDecoded() throws {
        // When
        try sut.save(Mock.testObject, forKey: "key1")
        // Then
        let loadedObject = try sut.load(key: "key1", type: TestObject.self)
        XCTAssertEqual(loadedObject, Mock.testObject)
        XCTAssertEqual(loadedObject?.text, "text 1")
        XCTAssertNotNil(userDefaults.object(forKey: "key1"))
    }
    
    func test_save_givenInvalidObject_thenThrowsError() throws {
        // Then: testObject2 cannot be encoded because it has Double.infinity
        XCTAssertThrowsError(try sut.save(Mock.testObject2, forKey: "key1"))
    }
    
    func test_load_givenDecoderFails_thenThrowsError() throws {
        // Given
        userDefaults.set("invalid json".data(using: .utf8), forKey: "key1")
        // Then
        XCTAssertThrowsError(try sut.load(key: "key1", type: TestObject.self))
    }
    
    func test_load_givenNoObjectInUserDefaults_thenReturnsNil() throws {
        // When
        let loadedObject = try sut.load(key: "invalid key", type: TestObject.self)
        // Then
        XCTAssertNil(loadedObject)
    }
}

private struct TestObject: Codable, Equatable {
    var text: String
}

private struct TestObject2: Codable, Equatable {
    var number: Double
}
