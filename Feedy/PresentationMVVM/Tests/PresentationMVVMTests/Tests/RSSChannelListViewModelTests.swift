//
//  RSSChannelListViewModelTests.swift
//
//
//  Created by Danijel Huis on 20.05.2024..
//

import XCTest
@testable import Domain
import TestUtility
import Combine
@testable import PresentationMVVM

final class RSSChannelListViewModelTests: XCTestCase {
    private var getRSSChannelsUseCase: MockGetRSSChannelsUseCase!
    private var removeRSSHistoryItemUseCase: MockRemoveRSSHistoryItemUseCase!
    private var coordinator: MockCoordinator!
    private var effectManager: EffectManager!
    private var sut: RSSChannelListViewModel!
    private var observationTracker: KeyPathObservationTracker<RSSChannelListViewModel, RSSChannelListViewModel.ViewStatus>!
    private var cancellables: Set<AnyCancellable> = []
    
    
    private struct Mock {
        static let uuid1 = UUID()
        static let uuid2 = UUID()
        static let historyItem1 = RSSHistoryItem.mock(id: uuid1,
                                                      channelURL: URL(string: "item1")!,
                                                      isFavourite: true)
        static let historyItem2 = RSSHistoryItem.mock(id: uuid2,
                                                      channelURL: URL(string: "item2")!,
                                                      isFavourite: false)
        
        static let historyItems = [historyItem1, historyItem2]
        
        static let channel1 = RSSChannel(title: "channel1", description: "description1", imageURL: URL(string: "image1"), items: [])
        static let channel2 = RSSChannel(title: "channel2", description: "description2", imageURL: URL(string: "image2"), items: [])
        static let channelsResponses = [
            RSSChannelResponse(historyItem: historyItem1, channel: .success(channel1)),
            RSSChannelResponse(historyItem: historyItem2, channel: .success(channel2))
        ]
        
        static let channels: [UUID: Result<RSSChannel, RSSChannelError>] = [uuid1: .success(channel1), uuid2: .success(channel2)]
        static let failedChannels: [UUID: Result<RSSChannel, RSSChannelError>] = [uuid1: .failure(.failedToLoad), uuid2: .failure(.failedToLoad)]
    }
    
    @MainActor override func setUp() async throws {
        resetAll()
    }
    
    @MainActor private func resetAll() {
        getRSSChannelsUseCase = .init()
        removeRSSHistoryItemUseCase = .init()
        coordinator = .init()
        effectManager = EffectManager()
        sut = .init(getRSSChannelsUseCase: getRSSChannelsUseCase,
                    removeRSSHistoryItemUseCase: removeRSSHistoryItemUseCase,
                    effectManager: effectManager,
                    coordinator: coordinator)
        observationTracker = .init(object: sut, keyPath: \.status)
    }
    
    @MainActor override func tearDown() {
        getRSSChannelsUseCase = nil
        removeRSSHistoryItemUseCase = nil
        coordinator = nil
        effectManager = nil
        sut = nil
    }
    
    // This will set channels on the state (it invokes getRSSChannelsUseCase).
    @MainActor private func setupState(channels: [RSSChannelResponse]) async {
        getRSSChannelsUseCase.subject.send(channels)
        
        await effectManager.wait()
        
        getRSSChannelsUseCase.getRSSChannelsCalls = 0
    }
    
    // MARK: - observeEnvironment -
    
    @MainActor func test_observeEnvironment_givenEmits_thenUpdatesState() async throws {
        // When: use case emits
        getRSSChannelsUseCase.subject.send(Mock.channelsResponses)
        await effectManager.wait()
        // Then: reloads channels
        XCTAssertEqual(sut.status.cellTitles, ["channel1", "channel2"])
    }
    
    // MARK: - actions -
    
    @MainActor func test_onFirstAppear_thenSetsLoadingState_thenLoadsItems() async throws {
        // Given
        getRSSChannelsUseCase.channelsToEmit = Mock.channelsResponses
        // When
        sut.onFirstAppear()
        await effectManager.wait()
        // Then
        XCTAssertEqual(observationTracker.getValues().contains(.loading(text: "common_loading".localizedOrRandom)), true)
        XCTAssertEqual(sut.status.cellTitles, ["channel1", "channel2"])
    }
    
    @MainActor func test_didTapRetry_thenSetsLoadingState_thenLoadsItems() async throws {
        // Given
        getRSSChannelsUseCase.channelsToEmit = Mock.channelsResponses
        // When
        sut.didTapRetry()
        await effectManager.wait()
        // Then
        XCTAssertEqual(observationTracker.getValues().contains(.loading(text: "common_loading".localizedOrRandom)), true)
        XCTAssertEqual(sut.status.cellTitles, ["channel1", "channel2"])
    }
    
    @MainActor func test_didInitiateRefresh_thenDoesntSetLoadingState_thenLoadsItems() async throws {
        // Given
        getRSSChannelsUseCase.channelsToEmit = Mock.channelsResponses
        // When
        await sut.didInitiateRefresh()
        // Then
        XCTAssertEqual(observationTracker.getValues().contains(.loading(text: "common_loading".localizedOrRandom)), false)
        XCTAssertEqual(sut.status.cellTitles, ["channel1", "channel2"])
    }
    
    @MainActor func test_didTapAddChannelButton_thenOpensAddScreen() async throws {
        // When
        sut.didTapAddChannelButton()
        await effectManager.wait()
        // Then
        XCTAssertEqual(coordinator.openRouteCalls.count, 1)
        XCTAssertEqual(coordinator.openRouteCalls.first, .rss(.add))
    }
    
    @MainActor func test_didTapRemoveHistoryItem_thenCallsUseCase() async throws {
        // Given
        await setupState(channels: Mock.channelsResponses)
        // When
        sut.didTapRemoveHistoryItem(historyItemID: Mock.uuid2)
        await effectManager.wait()
        // Then
        XCTAssertEqual(removeRSSHistoryItemUseCase.removeRSSHistoryItemCalls.count, 1)
        XCTAssertEqual(removeRSSHistoryItemUseCase.removeRSSHistoryItemCalls.first, Mock.uuid2)
    }
    
    @MainActor func test_didTapRemoveHistoryItem_givenFailure_thenDoesntSetStateToError() async throws {
        // Given
        await setupState(channels: Mock.channelsResponses)
        removeRSSHistoryItemUseCase.removeRSSHistoryItemError = MockError.generalError("removeRSSHistoryItemError")
        // When
        sut.didTapRemoveHistoryItem(historyItemID: Mock.uuid2)
        await effectManager.wait()
        // Then
        XCTAssertEqual(removeRSSHistoryItemUseCase.removeRSSHistoryItemCalls.count, 1)
        XCTAssertEqual(removeRSSHistoryItemUseCase.removeRSSHistoryItemCalls.first, Mock.uuid2)
        // Then: it doesn't set error state
        XCTAssertEqual(sut.status.isLoaded, true)
    }
    
    @MainActor func test_didSelectItem_thenOpensDetailsScreen() async throws {
        // Given
        await setupState(channels: Mock.channelsResponses)
        // When
        sut.didSelectItem(historyItemID: Mock.uuid1)
        await effectManager.wait()
        // Then
        XCTAssertEqual(coordinator.openRouteCalls.count, 1)
        XCTAssertEqual(coordinator.openRouteCalls.first, .rss(.details(rssHistoryItem: Mock.historyItem1, channel: Mock.channel1)))
    }
    
    @MainActor func test_didSelectItem_givenNoChannel_thenDoesNothing() async throws {
        // Given: only wrong channel present
        await setupState(channels: [RSSChannelResponse(historyItem: Mock.historyItem2, channel: .success(Mock.channel2))])
        // When
        sut.didSelectItem(historyItemID: Mock.uuid1)
        await effectManager.wait()
        // Then
        XCTAssertEqual(coordinator.openRouteCalls.count, 0)
    }
    
    @MainActor func test_didSelectItem_givenFailedChannel_thenDoesNothing() async throws {
        // Given: failure
        await setupState(channels: [RSSChannelResponse(historyItem: Mock.historyItem1, channel: .failure(.failedToLoad))])
        // When
        sut.didSelectItem(historyItemID: Mock.uuid1)
        await effectManager.wait()
        // Then
        XCTAssertEqual(coordinator.openRouteCalls.count, 0)
    }
    
    @MainActor func test_toggleFavourites_thenTogglesFavourites_thenFiltersList() async throws {
        // Given
        await setupState(channels: Mock.channelsResponses)
        // When
        sut.toggleFavourites()
        await effectManager.wait()
        // Then: toggles favourites, filters and refreshes list
        XCTAssertEqual(sut.isShowingFavourites, true)
        switch sut.status {
        case .loaded(let states):
            XCTAssertEqual(states.count, 1)
            XCTAssertEqual(states.first?.historyItemID, Mock.uuid1)
            XCTAssertEqual(states.first?.isFavourite, true)
        default: XCTFail("Invalid status")
        }
    }
    
    // MARK: - State -
    
    @MainActor func test_state_thenMapsCellStatesCorrectly() async throws {
        // When
        await setupState(channels: Mock.channelsResponses)
        // Then
        switch sut.status {
        case .loaded(let states):
            XCTAssertEqual(states.count, 2)
            XCTAssertEqual(states[0].historyItemID, Mock.uuid1)
            XCTAssertEqual(states[0].title, Mock.channel1.title)
            XCTAssertEqual(states[0].description, Mock.channel1.description)
            XCTAssertEqual(states[0].imageResource, .init(url: Mock.channel1.imageURL, placeholderSystemName: "newspaper"))
            XCTAssertEqual(states[0].isFavourite, true)
            
            XCTAssertEqual(states[1].historyItemID, Mock.uuid2)
            XCTAssertEqual(states[1].title, Mock.channel2.title)
            XCTAssertEqual(states[1].description, Mock.channel2.description)
            XCTAssertEqual(states[1].imageResource, .init(url: Mock.channel2.imageURL, placeholderSystemName: "newspaper"))
            XCTAssertEqual(states[1].isFavourite, false)
            
        default:
            XCTFail("Expected loaded state")
        }
    }
    
    @MainActor func test_state_givenFailedChannels_thenMapsCellStatesCorrectly() async throws {
        // Given: second item fails
        await setupState(channels: [.init(historyItem: Mock.historyItem1, channel: .success(Mock.channel1)), .init(historyItem: Mock.historyItem2, channel: .failure(.failedToLoad))])
        // Then
        switch sut.status {
        case .loaded(let states):
            XCTAssertEqual(states.count, 2)
            XCTAssertEqual(states[0].historyItemID, Mock.uuid1)
            XCTAssertEqual(states[0].title, Mock.channel1.title)
            XCTAssertEqual(states[0].description, Mock.channel1.description)
            XCTAssertEqual(states[0].imageResource, .init(url: Mock.channel1.imageURL, placeholderSystemName: "newspaper"))
            XCTAssertEqual(states[0].isFavourite, true)
            
            XCTAssertEqual(states[1].historyItemID, Mock.uuid2)
            XCTAssertEqual(states[1].title, "rss_list_failed_to_load_channel".localized)
            XCTAssertEqual(states[1].description, Mock.historyItem2.channelURL.absoluteString)
            XCTAssertEqual(states[1].imageResource, .init(url: nil, placeholderSystemName: "exclamationmark.triangle"))
            XCTAssertEqual(states[1].isFavourite, false)
            
        default:
            XCTFail("Expected loaded state")
        }
    }
    
    @MainActor func test_state_givenIsFavouriteFalse_givenNoCellStates_thenSetsEmptyScreen() async throws {
        // Given
        // historyItem2 is not favourite
        await setupState(channels: [])
        // Then
        XCTAssertEqual(sut.status, .empty(text: "rss_list_no_channels".localizedOrRandom))
    }
    
    @MainActor func test_state_givenIsFavouriteTrue_givenNoCellStates_thenSetsEmptyScreen() async throws {
        // Given
        sut.toggleFavourites()
        await effectManager.wait()
        // When
        // historyItem2 is not favourite
        await setupState(channels: [.init(historyItem: Mock.historyItem2, channel: .success(Mock.channel2))])
        // Then
        XCTAssertEqual(sut.status, .empty(text: "rss_list_no_favourites".localizedOrRandom))
    }
    
    @MainActor func test_state_givenLoadFailure_thenSetsErrorState() async throws {
        // Given
        getRSSChannelsUseCase.getRSSChannelsError = MockError.generalError("failed to load channels")
        // When
        await sut.didInitiateRefresh()
        // Then
        XCTAssertEqual(sut.status, .error(text: "rss_list_channel_failure".localizedOrRandom, retryText: "common_retry".localizedOrRandom))
    }
}

private extension RSSChannelListViewModel.ViewStatus {
    var isLoaded: Bool {
        switch self {
        case .empty: false
        case .loading: false
        case .loaded: true
        case .error: false
        }
    }
    
    var cellTitles: [String]? {
        switch self {
        case .empty: nil
        case .loading: nil
        case .loaded(let states): states.map({ $0.title })
        case .error: nil
        }
    }
}



