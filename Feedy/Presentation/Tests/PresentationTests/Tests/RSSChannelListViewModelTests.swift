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
@testable import Presentation

final class RSSChannelListViewModelTests: XCTestCase {
    private var getRSSHistoryItemsUseCase: MockGetRSSHistoryItemsUseCase!
    private var removeRSSHistoryItemUseCase: MockRemoveRSSHistoryItemUseCase!
    private var getRSSChannelsUseCase: MockGetRSSChannelsUseCase!
    private var updateLastReadItemIDUseCase: MockUpdateLastReadItemIDUseCase!
    private var coordinator: MockCoordinator!
    private var effectManager: SideEffectManager!
    private var sut: RSSChannelListViewModel!
    private var stateCalls = [RSSChannelListViewModel.State]()
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
        
        static let channels: [UUID: Result<RSSChannel, RSSChannelError>] = [uuid1: .success(channel1), uuid2: .success(channel2)]
        static let failedChannels: [UUID: Result<RSSChannel, RSSChannelError>] = [uuid1: .failure(.failedToLoad), uuid2: .failure(.failedToLoad)]
        
    }
    
    @MainActor override func setUp() async throws {
        resetAll()
    }
    
    @MainActor private func resetAll() {
        getRSSHistoryItemsUseCase = .init()
        removeRSSHistoryItemUseCase = .init()
        getRSSChannelsUseCase = .init()
        updateLastReadItemIDUseCase = .init()
        coordinator = .init()
        effectManager = SideEffectManager()
        sut = .init(getRSSHistoryItemsUseCase: getRSSHistoryItemsUseCase,
                    removeRSSHistoryItemUseCase: removeRSSHistoryItemUseCase,
                    getRSSChannelsUseCase: getRSSChannelsUseCase,
                    effectManager: effectManager,
                    coordinator: coordinator)
        
        sut.$state.sink { [weak self] state in
            self?.stateCalls.append(state)
        }.store(in: &cancellables)
        stateCalls.removeAll()
    }
    
    @MainActor override func tearDown() {
        getRSSHistoryItemsUseCase = nil
        removeRSSHistoryItemUseCase = nil
        getRSSChannelsUseCase = nil
        updateLastReadItemIDUseCase = nil
        coordinator = nil
        effectManager = nil
        sut = nil
    }
    
    @MainActor private func setupState(historyItems: [RSSHistoryItem], channels: [UUID: Result<RSSChannel, RSSChannelError>]?) async {
        if let channels {
            getRSSChannelsUseCase.getRSSChannelsResult = channels
        }
        
        // We are using .add action to set history items and channels
        getRSSHistoryItemsUseCase.subject.send(RSSHistoryEvent(reason: .add(historyItemID: UUID()), historyItems: historyItems))
        
        await effectManager.wait()
        
        stateCalls.removeAll()
        getRSSChannelsUseCase.getRSSChannelsCalls.removeAll()
    }
    
    // MARK: - observeEnvironment -
    
    @MainActor func test_environment_givenSentAllEvents_thenUpdatedOrReloadsAccordingly() async throws {
        // When: .update event
        getRSSChannelsUseCase.getRSSChannelsResult = Mock.channels
        getRSSHistoryItemsUseCase.subject.send(RSSHistoryEvent(reason: .update, historyItems: Mock.historyItems))
        await effectManager.wait()
        // Then: reloads channels
        XCTAssertEqual(sut.state.status.cellTitles, ["channel1", "channel2"])
        
        // When: .add event
        resetAll()
        getRSSChannelsUseCase.getRSSChannelsResult = Mock.channels
        getRSSHistoryItemsUseCase.subject.send(.init(reason: .add(historyItemID: UUID()), historyItems: Mock.historyItems))
        await effectManager.wait()
        // Then: reloads channels
        XCTAssertEqual(sut.state.status.cellTitles, ["channel1", "channel2"])

        // When: .remove event
        resetAll()
        getRSSChannelsUseCase.getRSSChannelsResult = Mock.channels
        getRSSHistoryItemsUseCase.subject.send(.init(reason: .remove(historyItemID: UUID()), historyItems: Mock.historyItems))
        await effectManager.wait()
        // Then: list shows errors which means list was refreshed and not reloaded
        XCTAssertEqual(sut.state.status.cellTitles, ["rss_list_failed_to_load_channel".localizedOrRandom, "rss_list_failed_to_load_channel".localizedOrRandom])

        // When: .favouriteStatusUpdated event
        resetAll()
        getRSSChannelsUseCase.getRSSChannelsResult = Mock.channels
        getRSSHistoryItemsUseCase.subject.send(.init(reason: .favouriteStatusUpdated(historyItemID: UUID()), historyItems: Mock.historyItems))
        await effectManager.wait()
        // Then: list shows errors which means list was refreshed and not reloaded
        XCTAssertEqual(sut.state.status.cellTitles, ["rss_list_failed_to_load_channel".localizedOrRandom, "rss_list_failed_to_load_channel".localizedOrRandom])

        // When: .didUpdateLastReadItemID event
        resetAll()
        getRSSChannelsUseCase.getRSSChannelsResult = Mock.channels
        getRSSHistoryItemsUseCase.subject.send(.init(reason: .didUpdateLastReadItemID(historyItemID: UUID()), historyItems: Mock.historyItems))
        await effectManager.wait()
        // Then: list shows errors which means list was refreshed and not reloaded
        XCTAssertEqual(sut.state.status.cellTitles, ["rss_list_failed_to_load_channel".localizedOrRandom, "rss_list_failed_to_load_channel".localizedOrRandom])
    }
    
    // MARK: - reduce -
    
    @MainActor func test_didTapAddChannelButton_thenOpensAddScreen() async throws {
        // When
        await sut.sendAsync(.didTapAddChannelButton)
        // Then
        XCTAssertEqual(coordinator.openRouteCalls.count, 1)
        XCTAssertEqual(coordinator.openRouteCalls.first, .rss(.add))
    }
    
    @MainActor func test_didSelectItem_thenOpensDetailsScreen() async throws {
        // Given
        await setupState(historyItems: Mock.historyItems, channels: Mock.channels)
        // When
        await sut.sendAsync(.didSelectItem(Mock.uuid1))
        // Then
        XCTAssertEqual(coordinator.openRouteCalls.count, 1)
        XCTAssertEqual(coordinator.openRouteCalls.first, .rss(.details(rssHistoryItem: Mock.historyItem1, channel: Mock.channel1)))
    }
    
    @MainActor func test_didSelectItem_givenNoHistoryItems_thenDoesNothing() async throws {
        // Given
        await setupState(historyItems: [], channels: Mock.channels)
        // When
        await sut.sendAsync(.didSelectItem(Mock.uuid1))
        // Then
        XCTAssertEqual(coordinator.openRouteCalls.count, 0)
    }
    
    @MainActor func test_didSelectItem_givenNoChannels_thenDoesNothing() async throws {
        // Given
        await setupState(historyItems: Mock.historyItems, channels: nil)
        // When
        await sut.sendAsync(.didSelectItem(Mock.uuid1))
        // Then
        XCTAssertEqual(coordinator.openRouteCalls.count, 0)
    }
    
    @MainActor func test_didSelectItem_givenFailedChannel_thenDoesNothing() async throws {
        // Given
        await setupState(historyItems: Mock.historyItems, channels: Mock.failedChannels)
        // When
        await sut.sendAsync(.didSelectItem(Mock.uuid1))
        // Then
        XCTAssertEqual(coordinator.openRouteCalls.count, 0)
    }
    
    @MainActor func test_toggleFavourites_thenTogglesFavourites_thenFiltersList() async throws {
        // Given
        await setupState(historyItems: Mock.historyItems, channels: Mock.channels)
        // When
        await sut.sendAsync(.toggleFavourites)
        // Then: toggles favourites, filters and refreshes list
        XCTAssertEqual(sut.state.isShowingFavourites, true)
        switch sut.state.status {
        case .loaded(let states):
            XCTAssertEqual(states.count, 1)
            XCTAssertEqual(states.first?.historyItemID, Mock.uuid1)
            XCTAssertEqual(states.first?.isFavourite, true)
        default: XCTFail("Invalid status")
        }
    }
    
    @MainActor func test_onFirstAppear_thenCallsGetHistoryItems() async throws {
        // When
        await sut.sendAsync(.onFirstAppear)
        // Then
        XCTAssertEqual(getRSSHistoryItemsUseCase.getRSSHistoryItemsCalls, 1)
    }
    
    @MainActor func test_onFirstAppear_givenFailure_thenSetsStateToError() async throws {
        // Given
        getRSSHistoryItemsUseCase.getRSSHistoryItemsError = MockError.generalError("history error")
        // When
        await sut.sendAsync(.onFirstAppear)
        // Then
        XCTAssertEqual(getRSSHistoryItemsUseCase.getRSSHistoryItemsCalls, 1)
        XCTAssertEqual(sut.state.status, .error(text: "rss_list_channel_failure".localizedOrRandom))
    }
    
    @MainActor func test_didInitiateRefresh_thenCallsGetHistoryItems() async throws {
        // When
        await sut.sendAsync(.didInitiateRefresh)
        // Then
        XCTAssertEqual(getRSSHistoryItemsUseCase.getRSSHistoryItemsCalls, 1)
    }
    
    @MainActor func test_didInitiateRefresh_givenFailure_thenSetsStateToError() async throws {
        // Given
        getRSSHistoryItemsUseCase.getRSSHistoryItemsError = MockError.generalError("history error")
        // When
        await sut.sendAsync(.didInitiateRefresh)
        // Then
        XCTAssertEqual(getRSSHistoryItemsUseCase.getRSSHistoryItemsCalls, 1)
        XCTAssertEqual(sut.state.status, .error(text: "rss_list_channel_failure".localizedOrRandom))
    }
    
    @MainActor func test_didTapRemoveHistoryItem_thenCallsUseCase() async throws {
        // Given
        await setupState(historyItems: Mock.historyItems, channels: Mock.channels)
        // When
        await sut.sendAsync(.didTapRemoveHistoryItem(Mock.uuid2))
        // Then
        XCTAssertEqual(removeRSSHistoryItemUseCase.removeRSSHistoryItemCalls.count, 1)
        XCTAssertEqual(removeRSSHistoryItemUseCase.removeRSSHistoryItemCalls.first, Mock.uuid2)
    }
    
    @MainActor func test_didTapRemoveHistoryItem_givenFailure_thenDoesntSetStateToError() async throws {
        // Given
        await setupState(historyItems: Mock.historyItems, channels: Mock.channels)
        removeRSSHistoryItemUseCase.removeRSSHistoryItemError = MockError.generalError("removeRSSHistoryItemError")
        // When
        await sut.sendAsync(.didTapRemoveHistoryItem(Mock.uuid2))
        // Then
        XCTAssertEqual(removeRSSHistoryItemUseCase.removeRSSHistoryItemCalls.count, 1)
        XCTAssertEqual(removeRSSHistoryItemUseCase.removeRSSHistoryItemCalls.first, Mock.uuid2)
        // Then: it doesn't set error state
        XCTAssertEqual(sut.state.status.isLoaded, true)
    }
    
    @MainActor func test_reloadRSSChannels_thenReloadsChannels() async throws {
        // When
        await setupState(historyItems: Mock.historyItems, channels: Mock.channels)
        // Then: refreshes channels and list
        XCTAssertEqual(sut.state.status.cellTitles, ["channel1", "channel2"])
        XCTAssertEqual(sut.state.status.isLoaded, true)
    }
    
    @MainActor func test_reloadRSSChannels_givenNoHistoryItems_thenSetsEmptyScreen() async throws {
        // When
        await setupState(historyItems: [], channels: Mock.channels)
        // Then
        XCTAssertEqual(sut.state.status, .empty(text: "rss_list_no_channels".localizedOrRandom))
    }
    
    @MainActor func test_refreshList_thenMapsStatesCorrectly() async throws {
        // When
        await setupState(historyItems: Mock.historyItems, channels: Mock.channels)
        // Then
        switch sut.state.status {
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
    
    @MainActor func test_refreshList_givenFailedChannels_thenMapsStateCorrectly() async throws {
        // Given: second item fails
        await setupState(historyItems: Mock.historyItems, channels: [Mock.uuid1: .success(Mock.channel1), Mock.uuid2: .failure(.failedToLoad)])
        // Then
        switch sut.state.status {
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
    
    @MainActor func test_refreshList_givenIsFavourite_givenNoCellStates_thenSetsEmptyScreen() async throws {
        // Given
        await sut.sendAsync(.toggleFavourites)
        await setupState(historyItems: [Mock.historyItem2], channels: Mock.channels) // historyItem2 is not favourite
        // Then
        XCTAssertEqual(sut.state.status, .empty(text: "rss_list_no_favourites".localizedOrRandom))
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
        case .empty(let text): nil
        case .loading(let text): nil
        case .loaded(let states): 
            states.map({ $0.title })
        case .error(let text): nil
        }
    }
}

