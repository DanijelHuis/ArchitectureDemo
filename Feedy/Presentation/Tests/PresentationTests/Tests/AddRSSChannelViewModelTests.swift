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
@testable import Presentation

final class AddRSSChannelViewModelTests: XCTestCase {
    private var validateRSSChannelUseCase: MockValidateRSSChannelUseCase!
    private var addRSSHistoryItemUseCase: MockAddRSSHistoryItemUseCase!
    private var coordinator: MockCoordinator!
    private var effectManager: SideEffectManager!
    private var sut: AddRSSChannelViewModel!
    
    private var stateCalls = [AddRSSChannelViewModel.State]()
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
        
        sut.$state.sink { [weak self] state in
            self?.stateCalls.append(state)
        }.store(in: &cancellables)
        stateCalls.removeAll()
                
        sut.onFinished = { [weak self] in
            self?.didFinish = true
        }
    }
    
    override func tearDown() {
        validateRSSChannelUseCase = nil
        addRSSHistoryItemUseCase = nil
        effectManager = nil
        sut = nil
    }
    
    @MainActor private func setToErrorState() async {
        validateRSSChannelUseCase.validateRSSChannelResult = false
        await sut.sendAsync(.didTapAddButton)
        XCTAssertEqual(sut.state.status.isError, true)
    }
        
    @MainActor func test_init_thenSetsStateCorrectly() {
        XCTAssertEqual(sut.state.status, .idle)
        XCTAssertEqual(sut.state.channelURL, "")
        XCTAssertEqual(sut.state.title, "rss_add_title".localizedOrRandom)
        XCTAssertEqual(sut.state.placeholder, "rss_add_url_placeholder".localizedOrRandom)
        XCTAssertEqual(sut.state.buttonTitle, "rss_add_button".localizedOrRandom)
    }
    
    @MainActor func test_didChangeChannelURLText_thenChangesURL() async throws {
        // When
        await sut.sendAsync(.didChangeChannelURLText(Mock.url))
        // Then
        XCTAssertEqual(sut.state.channelURL, Mock.url)
    }
    
    @MainActor func test_didChangeChannelURLText_givenErrorState_thenChangesStateToIdle() async throws {
        // Given
        await setToErrorState()
        // When
        await sut.sendAsync(.didChangeChannelURLText(Mock.url))
        // Then
        XCTAssertEqual(sut.state.status, .idle)
    }
    
    @MainActor func test_didTapAddButton_givenEverythingSucceeds_thenAddsHistoryItem_thenCallsOnFinish() async throws {
        // Given
        validateRSSChannelUseCase.validateRSSChannelResult = true
        addRSSHistoryItemUseCase.addRSSHistoryItemError = nil
        await sut.sendAsync(.didChangeChannelURLText(Mock.url))
        stateCalls.removeAll()
        // When
        await sut.sendAsync(.didTapAddButton)
        // Then: check that it sets validating state
        XCTAssertEqual(stateCalls.map({ $0.status.isValidating }).contains(true), true)
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
        await sut.sendAsync(.didChangeChannelURLText(Mock.invalidURL))
        // When
        await sut.sendAsync(.didTapAddButton)
        // Then
        XCTAssertEqual(didFinish, false)
        XCTAssertEqual(sut.state.status, .error(message: "rss_add_invalid_url".localizedOrRandom))
    }
    
    
    @MainActor func test_didTapAddButton_givenValidateFails_thenSetsErrorState_thenDoesntCallOnFinish() async throws {
        // Given
        validateRSSChannelUseCase.validateRSSChannelResult = false
        addRSSHistoryItemUseCase.addRSSHistoryItemError = nil
        await sut.sendAsync(.didChangeChannelURLText(Mock.url))
        // When
        await sut.sendAsync(.didTapAddButton)
        // Then
        XCTAssertEqual(didFinish, false)
        XCTAssertEqual(sut.state.status, .error(message: "rss_add_failed_to_validate".localizedOrRandom))
    }
    
    @MainActor func test_didTapAddButton_givenAddFails_thenSetsErrorState_thenDoesntCallOnFinish() async throws {
        // Given
        validateRSSChannelUseCase.validateRSSChannelResult = true
        addRSSHistoryItemUseCase.addRSSHistoryItemError = Mock.addError
        await sut.sendAsync(.didChangeChannelURLText(Mock.url))
        // When
        await sut.sendAsync(.didTapAddButton)
        // Then
        XCTAssertEqual(didFinish, false)
        XCTAssertEqual(sut.state.status, .error(message: "rss_add_failed_to_add".localizedOrRandom))
    }
    
    @MainActor func test_didTapAddButton_givenAddFailsWithURLAlreadyExists_thenSetsErrorState_thenDoesntCallOnFinish() async throws {
        // Given
        validateRSSChannelUseCase.validateRSSChannelResult = true
        addRSSHistoryItemUseCase.addRSSHistoryItemError = RSSHistoryRepositoryError.urlAlreadyExists
        await sut.sendAsync(.didChangeChannelURLText(Mock.url))
        // When
        await sut.sendAsync(.didTapAddButton)
        // Then
        XCTAssertEqual(didFinish, false)
        XCTAssertEqual(sut.state.status, .error(message: "rss_add_url_exists".localizedOrRandom))
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
