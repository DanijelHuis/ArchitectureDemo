//
//  DefaultValidateRSSChannelUseCaseTests.swift
//
//
//  Created by Danijel Huis on 20.05.2024..
//

import XCTest
import TestUtility
@testable import Domain

final class DefaultValidateRSSChannelUseCaseTests: XCTestCase {
    private var repository: MockRSSRepository!
    private var sut: DefaultValidateRSSChannelUseCase!
    
    private struct Mock {
        static let url = URL(string: "https://channel1")!
    }
    
    @UnitTestActor override func setUp() {
        repository = .init()
        sut = .init(repository: repository)
    }
    
    @UnitTestActor override func tearDown() {
        repository = nil
        sut = nil
    }
    
    @UnitTestActor func test_validateRSSChannel_givenSuccess_thenReturnsTrue() async {
        // Given
        repository.getRSSChannelResult = .success(RSSChannel.mock())
        // When
        let result = await sut.validateRSSChannel(url: Mock.url)
        // Then
        XCTAssertEqual(result, true)
    }
    
    @UnitTestActor func test_validateRSSChannel_givenFailure_thenReturnsFalse() async {
        // Given
        repository.getRSSChannelResult = .failure(MockError.generalError("validate error"))
        // When
        let result = await sut.validateRSSChannel(url: Mock.url)
        // Then
        XCTAssertEqual(result, false)
    }
}
