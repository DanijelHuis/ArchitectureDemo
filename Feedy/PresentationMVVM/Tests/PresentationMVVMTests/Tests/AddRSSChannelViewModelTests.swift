//
//  AddRSSChannelViewModelTests.swift
//
//
//  Created by Danijel Huis on 21.05.2024..
//

import XCTest
import Combine
import Domain
import TestUtility
@testable import PresentationMVVM

final class AddRSSChannelViewModelTests: XCTestCase {
    private var validateRSSChannelUseCase: MockValidateRSSChannelUseCase!
    private var addRSSHistoryItemUseCase: MockAddRSSHistoryItemUseCase!
    private var coordinator: MockCoordinator!
    private var effectManager: EffectManager!
    private var sut: AddRSSChannelViewModel!
    private var observationTracker: KeyPathObservationTracker<AddRSSChannelViewModel, AddRSSChannelViewModel.ViewStatus>!
    private var cancellables: Set<AnyCancellable> = []
    private var didFinish = false
    
    private struct Mock {
        static let url = "https://test1.com"
        static let invalidURL = ""
        static let addError = MockError.generalError("add fail")
    }
    
    @MainActor override func setUp() {
        validateRSSChannelUseCase = .init()
        addRSSHistoryItemUseCase = .init()
        effectManager = .init()
        sut = .init(validateRSSChannelUseCase: validateRSSChannelUseCase, addRSSHistoryItemUseCase: addRSSHistoryItemUseCase, effectManager: effectManager)
        observationTracker = .init(object: sut, keyPath: \.status)

        sut.onFinished = { [weak self] in
            self?.didFinish = true
        }
    }
    
    override func tearDown() {
        validateRSSChannelUseCase = nil
        addRSSHistoryItemUseCase = nil
        effectManager = nil
        observationTracker = nil
        sut = nil
    }
    
    @MainActor private func setToErrorState() async {
        validateRSSChannelUseCase.validateRSSChannelResult = false
        sut.didTapAddButton()
        await effectManager.wait()
        XCTAssertEqual(sut.status.isError, true)
    }
        
    @MainActor func test_init_thenSetsStateCorrectly() {
        XCTAssertEqual(sut.status, .idle)
        XCTAssertEqual(sut.channelURL, "")
        XCTAssertEqual(sut.title, "rss_add_title".localizedOrRandom)
        XCTAssertEqual(sut.placeholder, "rss_add_url_placeholder".localizedOrRandom)
        XCTAssertEqual(sut.buttonTitle, "rss_add_button".localizedOrRandom)
    }
    
    @MainActor func test_setChannelURL_thenChangesURL() async throws {
        // When
        sut.channelURL = Mock.url
        // Then
        XCTAssertEqual(sut.channelURL, Mock.url)
    }
    
    @MainActor func test_didChangeChannelURLText_givenErrorState_thenChangesStateToIdle() async throws {
        // Given
        await setToErrorState()
        // When
        sut.channelURL = Mock.url
        // Then
        XCTAssertEqual(sut.status, .idle)
    }
    
    @MainActor func test_didTapAddButton_givenEverythingSucceeds_thenAddsHistoryItem_thenCallsOnFinish() async throws {
        // Given
        validateRSSChannelUseCase.validateRSSChannelResult = true
        addRSSHistoryItemUseCase.addRSSHistoryItemError = nil
        sut.channelURL = Mock.url
        // When
        sut.didTapAddButton()
        await effectManager.wait()
        // Then: check that it sets validating state
        XCTAssertEqual(observationTracker.getValues().map({ $0.isValidating }).contains(true), true)
        // Then check that it adds history item
        XCTAssertEqual(addRSSHistoryItemUseCase.addRSSHistoryItemCalls.count, 1)
        XCTAssertEqual(addRSSHistoryItemUseCase.addRSSHistoryItemCalls.first?.absoluteString, Mock.url)
        // Then: calls finish
        XCTAssertEqual(didFinish, true)
    }
    
    @MainActor func test_didTapAddButton_givenInvalidURL_thenSetsErrorState() async throws {
        // Given
        validateRSSChannelUseCase.validateRSSChannelResult = true
        addRSSHistoryItemUseCase.addRSSHistoryItemError = nil
        sut.channelURL = Mock.invalidURL
        // When
        sut.didTapAddButton()
        await effectManager.wait()
        // Then
        XCTAssertEqual(didFinish, false)
        XCTAssertEqual(sut.status, .error(message: "rss_add_invalid_url".localizedOrRandom))
    }
    
    
    @MainActor func test_didTapAddButton_givenValidateFails_thenSetsErrorState_thenDoesntCallOnFinish() async throws {
        // Given
        validateRSSChannelUseCase.validateRSSChannelResult = false
        addRSSHistoryItemUseCase.addRSSHistoryItemError = nil
        sut.channelURL = Mock.url
        // When
        sut.didTapAddButton()
        await effectManager.wait()
        // Then
        XCTAssertEqual(didFinish, false)
        XCTAssertEqual(sut.status, .error(message: "rss_add_failed_to_validate".localizedOrRandom))
    }
    
    @MainActor func test_didTapAddButton_givenAddFails_thenSetsErrorState_thenDoesntCallOnFinish() async throws {
        // Given
        validateRSSChannelUseCase.validateRSSChannelResult = true
        addRSSHistoryItemUseCase.addRSSHistoryItemError = Mock.addError
        sut.channelURL = Mock.url
        // When
        sut.didTapAddButton()
        await effectManager.wait()
        // Then
        XCTAssertEqual(didFinish, false)
        XCTAssertEqual(sut.status, .error(message: "rss_add_failed_to_add".localizedOrRandom))
    }
    
    @MainActor func test_didTapAddButton_givenAddFailsWithURLAlreadyExists_thenSetsErrorState_thenDoesntCallOnFinish() async throws {
        // Given
        validateRSSChannelUseCase.validateRSSChannelResult = true
        addRSSHistoryItemUseCase.addRSSHistoryItemError = RSSHistoryRepositoryError.urlAlreadyExists
        sut.channelURL = Mock.url
        // When
        sut.didTapAddButton()
        await effectManager.wait()
        // Then
        XCTAssertEqual(didFinish, false)
        XCTAssertEqual(sut.status, .error(message: "rss_add_url_exists".localizedOrRandom))
    }
}

private extension AddRSSChannelViewModel.ViewStatus {
    var isError: Bool {
        switch self {
        case .idle: false
        case .validating: false
        case .error: true
        }
    }
    
    var isValidating: Bool {
        switch self {
        case .idle: false
        case .validating: true
        case .error: false
        }
    }
}

