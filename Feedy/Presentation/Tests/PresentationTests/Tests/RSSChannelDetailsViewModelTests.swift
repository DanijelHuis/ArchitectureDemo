//
//  RSSChannelDetailsViewModelTests.swift
//
//
//  Created by Danijel Huis on 21.05.2024..
//

import XCTest
import Combine
import TestUtility
import Domain
@testable import Presentation

final class RSSChannelDetailsViewModelTests: XCTestCase {
    private var getRSSHistoryItemsUseCase: MockGetRSSHistoryItemsUseCase!
    private var getRSSChannelUseCase: MockGetRSSChannelUseCase!
    private var changeHistoryItemFavouriteStatusUseCase: MockChangeHistoryItemFavouriteStatusUseCase!
    private var updateLastReadItemIDUseCase: MockUpdateLastReadItemIDUseCase!
    private var effectManager: SideEffectManager!
    private var coordinator: MockCoordinator!
    private var sut: RSSChannelDetailsViewModel!
    
    private var stateCalls = [RSSChannelDetailsViewModel.State]()
    private var cancellables: Set<AnyCancellable> = []
    private var didFinish = false
    
    private struct Mock {
        static let link = URL(string: "link1")!
        static let channelError = MockError.generalError("channel error")
        static let uuid1 = UUID()
        static let uuid2 = UUID()
        static let historyItem1 = RSSHistoryItem.mock(id: uuid1,
                                                      channelURL: URL(string: "item1")!,
                                                      isFavourite: true)
        static let historyItem2 = RSSHistoryItem.mock(id: uuid2,
                                                      channelURL: URL(string: "item2")!,
                                                      isFavourite: false)
        
        static let historyItems = [historyItem1, historyItem2]
        
        static let item1 = RSSItem.mock(guid: "item 1 guid")
        static let item2 = RSSItem.mock(guid: "item 2 guid")
        static let channel1 = RSSChannel(title: "channel1", description: "description1", imageURL: URL(string: "image1"), items: [item1, item2])
        static let channel2 = RSSChannel(title: "channel2", description: "description2", imageURL: URL(string: "image2"), items: [])
        static var updatedChannel1: RSSChannel {
            let item1Updated = RSSItem.mock(guid: "item 1 guid", title: "updated item 1 title", description: item1.description, link: item1.link, imageURL: item1.imageURL, pubDate: item1.pubDate)
            let item2Updated = RSSItem.mock(guid: "item 2 guid", title: "updated item 2 title", description: item2.description, link: item2.link, imageURL: item2.imageURL, pubDate: item2.pubDate)
            return .init(title: "updated title", description: channel1.description, imageURL: channel1.imageURL, items: [item1Updated, item2Updated])
        }
        static var updatedChannel1WithoutItems: RSSChannel {
            .init(title: "updated title", description: channel1.description, imageURL: channel1.imageURL, items: [])
        }
        static let channels: [UUID: Result<RSSChannel, Error>] = [uuid1: .success(channel1), uuid2: .success(channel2)]
    }
    
    @MainActor override func setUp() {
        resetAll()
    }
    
    @MainActor private func resetAll() {
        getRSSHistoryItemsUseCase = .init()
        getRSSChannelUseCase = .init()
        changeHistoryItemFavouriteStatusUseCase = .init()
        updateLastReadItemIDUseCase = .init()
        effectManager = .init()
        coordinator = .init()
        sut = createSUT(historyItem: Mock.historyItem1, channel: Mock.channel1)
        sut.$state.sink { [weak self] state in
            self?.stateCalls.append(state)
        }.store(in: &cancellables)
        stateCalls.removeAll()
    }
    
    @MainActor override func tearDown() {
        getRSSHistoryItemsUseCase = nil
        getRSSChannelUseCase = nil
        changeHistoryItemFavouriteStatusUseCase = nil
        updateLastReadItemIDUseCase = nil
        effectManager = nil
        coordinator = nil
        sut = nil
    }
    
    @MainActor func createSUT(historyItem: RSSHistoryItem, channel: RSSChannel) -> RSSChannelDetailsViewModel {
        .init(rssHistoryItem: historyItem,
              rssChannel: channel,
              getRSSHistoryItemsUseCase: getRSSHistoryItemsUseCase,
              getRSSChannelUseCase: getRSSChannelUseCase,
              changeHistoryItemFavouriteStatusUseCase: changeHistoryItemFavouriteStatusUseCase,
              updateLastReadItemIDUseCase: updateLastReadItemIDUseCase,
              effectManager: effectManager,
              coordinator: coordinator)
    }
    
    // MARK: - Init -
    
    @MainActor func test_init_thenSetsInitialState() async throws {
        // Then
        XCTAssertEqual(sut.state.title, Mock.channel1.title)
        XCTAssertEqual(sut.state.isFavourite, true)
    }
    
    // MARK: - observeEnvironment -
    
    @MainActor func test_environment_givenMatchingHistoryItem_thenUpdatesStates() async throws {
        var historyItem1 = Mock.historyItem1
        historyItem1.isFavourite.toggle()
        // When: .update event
        getRSSHistoryItemsUseCase.subject.send(RSSHistoryEvent(reason: .update, historyItems: [historyItem1]))
        await effectManager.wait()
        // Then: updates isFavourite
        XCTAssertEqual(sut.state.isFavourite, !Mock.historyItem1.isFavourite)
    }
    
    @MainActor func test_environment_givenNoMatchingHistoryItem_thenDoesNothing() async throws {
        // When: .update event
        getRSSHistoryItemsUseCase.subject.send(RSSHistoryEvent(reason: .update, historyItems: [Mock.historyItem2]))
        await effectManager.wait()
        // Then: does nothing
        XCTAssertEqual(stateCalls.count, 0)
    }
    
    // MARK: - Actions -
    
    @MainActor func test_onFirstAppear_thenSetsInitialState() async throws {
        // Given
        getRSSChannelUseCase.getRSSChannelResult = .success(Mock.updatedChannel1)
        // Calling onFirstAppear so it sets state to .loaded, that way we can test if second onFirstAppear sets state to .loading (otherwise we cannot test because initial state is .loading).
        await sut.sendAsync(.onFirstAppear)
        stateCalls.removeAll()
        // When
        await sut.sendAsync(.onFirstAppear)
        // Then: sets loading
        XCTAssertEqual(stateCalls.map({ $0.status.isLoading }).contains(true), true)
        // Then: checking that it loaded new channel and set it up, other stuff is tested elsewhere
        XCTAssertEqual(sut.state.title, Mock.updatedChannel1.title)
    }
    
    @MainActor func test_didInitiateRefresh_thenSetsInitialState() async throws {
        // Given
        getRSSChannelUseCase.getRSSChannelResult = .success(Mock.updatedChannel1)
        // Calling onFirstAppear so it sets state to .loaded, that way we can test if didInitiateRefresh sets state to .loading (otherwise we cannot test because initial state is .loading).
        await sut.sendAsync(.onFirstAppear)
        XCTAssertEqual(sut.state.status.isLoaded, true)
        stateCalls.removeAll()
        // When
        await sut.sendAsync(.didInitiateRefresh)
        // Then: doesn't set loading
        XCTAssertEqual(stateCalls.map({ $0.status.isLoading }).contains(true), false)
        // Then: checking that it loaded new channel and set it up, other stuff is tested elsewhere
        XCTAssertEqual(sut.state.title, Mock.updatedChannel1.title)
    }
    
    @MainActor func test_toggleFavourites_thenTogglesFavourites() async throws {
        // When
        await sut.sendAsync(.toggleFavourites)
        // Then
        XCTAssertEqual(changeHistoryItemFavouriteStatusUseCase.changeFavouriteStatusCalls.count, 1)
        XCTAssertEqual(changeHistoryItemFavouriteStatusUseCase.changeFavouriteStatusCalls.first?.historyItemID, Mock.uuid1)
        XCTAssertEqual(changeHistoryItemFavouriteStatusUseCase.changeFavouriteStatusCalls.first?.isFavourite, false)
    }
    
    @MainActor func test_didTapOnRSSItem_thenCallsCoordinator() async throws {
        // When
        await sut.sendAsync(.didTapOnRSSItem(Mock.link))
        // Then
        XCTAssertEqual(coordinator.openRouteCalls, [.common(.safari(url: Mock.link))])
    }
    
    @MainActor func test_didTapOnRSSItem_givenNilLink_thenDoesntCallCoordinator() async throws {
        // When
        await sut.sendAsync(.didTapOnRSSItem(nil))
        // Then
        XCTAssertEqual(coordinator.openRouteCalls.count, 0)
    }
    
    @MainActor func test_loadRSSChannel_givenLoadedChannel_thenSetsNewChannel_thenUpdatesTitle() async throws {
        // Given
        getRSSChannelUseCase.getRSSChannelResult = .success(Mock.updatedChannel1)
        // When
        await sut.sendAsync(.didInitiateRefresh)
        // Then
        XCTAssertEqual(sut.state.title, "updated title")
        XCTAssertEqual(sut.state.status.isLoaded, true)
        switch sut.state.status {
        case .loaded(let cellStates):
            // Just testing that it mapped new cell states, not testing everything because it is tested in RSSChannelItemListCellStateMapperTests.
            XCTAssertEqual(cellStates.count, 2)
            XCTAssertEqual(cellStates[0].title, "updated item 1 title")
            XCTAssertEqual(cellStates[1].title, "updated item 2 title")

        default:
            XCTFail("Invalid status")
        }
        
        XCTAssertEqual(updateLastReadItemIDUseCase.updateLastReadItemIDCalls.count, 1)
        XCTAssertEqual(updateLastReadItemIDUseCase.updateLastReadItemIDCalls.first?.historyItemID, Mock.uuid1)
        XCTAssertEqual(updateLastReadItemIDUseCase.updateLastReadItemIDCalls.first?.lastItemID, "item 1 guid")
    }
    
    @MainActor func test_loadRSSChannel_givenLoadedChannelWithoutItems_thenSetsStatusToEmpty() async throws {
        // Given
        getRSSChannelUseCase.getRSSChannelResult = .success(Mock.updatedChannel1WithoutItems)
        // When
        await sut.sendAsync(.didInitiateRefresh)
        // Then
        XCTAssertEqual(sut.state.title, "updated title")
        XCTAssertEqual(sut.state.status, .empty(text: "rss_details_no_items".localizedOrRandom))
    }
    
    @MainActor func test_loadRSSChannel_givenLoadChannelFails_thenUsesCurrentChannel_thenDoesntSetErrorStatus() async throws {
        // Given
        getRSSChannelUseCase.getRSSChannelResult = .failure(Mock.channelError)
        // When
        await sut.sendAsync(.didInitiateRefresh)
        // Then
        XCTAssertEqual(sut.state.title, "channel1")
        XCTAssertEqual(sut.state.status.isLoaded, true)
    }
}

private extension RSSChannelDetailsViewModel.ViewStatus {
    var isLoaded: Bool {
        switch self {
        case .empty: false
        case .loading: false
        case .loaded: true
        }
    }
    
    var isLoading: Bool {
        switch self {
        case .empty: false
        case .loading: true
        case .loaded: false
        }
    }
}

