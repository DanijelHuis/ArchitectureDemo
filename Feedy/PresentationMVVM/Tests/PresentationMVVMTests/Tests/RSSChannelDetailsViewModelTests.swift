//
//  RSSChannelDetailsViewModelTests.swift
//
//
//  Created by Danijel Huis on 21.05.2024..
//

import XCTest
import Combine
import TestUtility
import CommonUI
@testable import Domain
@testable import PresentationMVVM
 
final class RSSChannelDetailsViewModelTests: XCTestCase {
    private var getRSSChannelsUseCase: MockGetRSSChannelsUseCase!
    private var getRSSChannelUseCase: MockGetRSSChannelUseCase!
    private var changeHistoryItemFavouriteStatusUseCase: MockChangeHistoryItemFavouriteStatusUseCase!
    private var effectManager: EffectManager!
    private var coordinator: MockCoordinator!
    private var sut: RSSChannelDetailsViewModel!
    private var observationTracker: KeyPathObservationTracker<RSSChannelDetailsViewModel, RSSChannelDetailsViewModel.ViewStatus>!
    private var didFinish = false
    
    // This is need to test async code.
    override func invokeTest() {
        withMainSerialExecutor {
            super.invokeTest()
        }
    }
    
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
        
        static let item1 = RSSItem.mock(guid: "item 1 guid", title: "title1",
                                        description: "description1",
                                        link: URL(string: "link1"),
                                        imageURL: URL(string: "image1"),
                                        pubDate: Date(timeIntervalSince1970: 0))
        static let item2 = RSSItem.mock(guid: "item 2 guid", title: "title2",
                                        description: "description2",
                                        link: URL(string: "link2"),
                                        imageURL: URL(string: "image2"),
                                        pubDate: Date(timeIntervalSince1970: 24 * 60 * 60))
        
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
    
    @MainActor override func setUp() async throws {
        Container.locale = Locale(identifier: "en")
        Container.timeZone = TimeZone(secondsFromGMT: 0)!
        await resetAll()
    }
    
    @MainActor private func resetAll() async {
        getRSSChannelsUseCase = .init()
        getRSSChannelUseCase = .init()
        changeHistoryItemFavouriteStatusUseCase = .init()
        effectManager = .init()
        coordinator = .init()
        sut = createSUT(historyItem: Mock.historyItem1, channel: Mock.channel1)
        observationTracker = .init(object: sut, keyPath: \.status)
        await yieldTasks()  // Waiting for Task in observeEnvironment
    }
    
    @MainActor override func tearDown() {
        getRSSChannelsUseCase = nil
        getRSSChannelUseCase = nil
        changeHistoryItemFavouriteStatusUseCase = nil
        effectManager = nil
        coordinator = nil
        sut = nil
        observationTracker = nil
    }
    
    @MainActor func createSUT(historyItem: RSSHistoryItem, channel: RSSChannel) -> RSSChannelDetailsViewModel {
        .init(rssHistoryItem: historyItem,
              rssChannel: channel,
              getRSSChannelsUseCase: getRSSChannelsUseCase,
              getRSSChannelUseCase: getRSSChannelUseCase,
              changeHistoryItemFavouriteStatusUseCase: changeHistoryItemFavouriteStatusUseCase,
              effectManager: effectManager,
              coordinator: coordinator)
    }
    
    // MARK: - Init -
    
    @MainActor func test_init_thenSetsInitialState() async throws {
        // Then
        XCTAssertEqual(sut.title, Mock.channel1.title)
        XCTAssertEqual(sut.isFavourite, true)
    }
    
    // MARK: - observeEnvironment -
    
    @MainActor func test_observeEnvironment_givenMatchingHistoryItem_thenUpdatesStates() async throws {
        // Given
        var historyItem1 = Mock.historyItem1
        historyItem1.isFavourite = false
        // When
        getRSSChannelsUseCase.subject.send([.init(historyItem: historyItem1, channel: .success(Mock.channel1))])
        await yieldTasks()
        // Then
        XCTAssertEqual(sut.isFavourite, false)  // Original item is true, this means it changed it.
    }
    
    @MainActor func test_environment_givenNoMatchingHistoryItem_thenDoesNothing() async throws {
        // Given
        var historyItem2 = Mock.historyItem2
        historyItem2.isFavourite = false
        // When
        getRSSChannelsUseCase.subject.send([.init(historyItem: historyItem2, channel: .success(Mock.channel2))])
        await yieldTasks()
        // Then: does nothing
        XCTAssertEqual(sut.isFavourite, true) // Original item is true, this means it didn't changed it.
    }
    
    
    // MARK: - Actions -
    
    @MainActor func test_onFirstAppear_thenSetsInitialState() async throws {
        // Given
        getRSSChannelUseCase.getRSSChannelResult = .success(Mock.updatedChannel1)
        // When
        sut.onFirstAppear()
        await yieldTasks()
        // Then: sets loading
        XCTAssertEqual(observationTracker.getValues().contains(.loading(text: "common_loading".localizedOrRandom)), true)
        // Then: checking that it loaded new channel and set it up, other stuff is tested elsewhere
        XCTAssertEqual(sut.title, Mock.updatedChannel1.title)
    }
    
    @MainActor func test_didInitiateRefresh_thenSetsInitialState() async throws {
        // Given
        getRSSChannelUseCase.getRSSChannelResult = .success(Mock.updatedChannel1)
        // When
        await sut.didInitiateRefresh()
        // Then: doesn't set loading
        XCTAssertEqual(observationTracker.getValues().contains(.loading(text: "common_loading".localizedOrRandom)), false)
        // Then: checking that it loaded new channel and set it up, other stuff is tested elsewhere
        XCTAssertEqual(sut.title, Mock.updatedChannel1.title)
    }
    
    @MainActor func test_toggleFavourites_thenTogglesFavourites() async throws {
        // When
        sut.toggleFavourites()
        await yieldTasks()
        // Then
        XCTAssertEqual(changeHistoryItemFavouriteStatusUseCase.changeFavouriteStatusCalls.count, 1)
        XCTAssertEqual(changeHistoryItemFavouriteStatusUseCase.changeFavouriteStatusCalls.first?.historyItemID, Mock.uuid1)
        XCTAssertEqual(changeHistoryItemFavouriteStatusUseCase.changeFavouriteStatusCalls.first?.isFavourite, false)
    }
    
    @MainActor func test_didTapOnRSSItem_thenCallsCoordinator() async throws {
        // When
        sut.didTapOnRSSItem(link: Mock.link)
        await yieldTasks()
        // Then
        XCTAssertEqual(coordinator.openRouteCalls, [.common(.safari(url: Mock.link))])
    }
    
    @MainActor func test_didTapOnRSSItem_givenNilLink_thenDoesntCallCoordinator() async throws {
        // When
        sut.didTapOnRSSItem(link: nil)
        await yieldTasks()
        // Then
        XCTAssertEqual(coordinator.openRouteCalls.count, 0)
    }
    
    @MainActor func test_loadRSSChannel_givenLoadedChannel_thenSetsNewChannel_thenMapsEverythingCorrectly() async throws {
        // Given
        getRSSChannelUseCase.getRSSChannelResult = .success(Mock.updatedChannel1)
        // When
        await sut.didInitiateRefresh()
        // Then
        XCTAssertEqual(sut.title, "updated title")
        XCTAssertEqual(sut.status.isLoaded, true)
        switch sut.status {
        case .loaded(let items):
            XCTAssertEqual(items.count, 2)
            XCTAssertEqual(items.first?.id, "item 1 guid")
            XCTAssertEqual(items.first?.title, "updated item 1 title")
            XCTAssertEqual(items.first?.description, "description1")
            XCTAssertEqual(items.first?.imageURL?.absoluteString, "image1")
            XCTAssertEqual(items.first?.link?.absoluteString, "link1")
            XCTAssertEqual(items.first?.publishDate, "January 1, 1970 at 12:00 AM")
            
            XCTAssertEqual(items.last?.id, "item 2 guid")
            XCTAssertEqual(items.last?.title, "updated item 2 title")
            XCTAssertEqual(items.last?.description, "description2")
            XCTAssertEqual(items.last?.imageURL?.absoluteString, "image2")
            XCTAssertEqual(items.last?.link?.absoluteString, "link2")
            XCTAssertEqual(items.last?.publishDate, "January 2, 1970 at 12:00 AM")
            
        default:
            XCTFail("Invalid status")
        }        
    }
    
    @MainActor func test_loadRSSChannel_givenLoadedChannelWithoutItems_thenSetsStatusToEmpty() async throws {
        // Given
        getRSSChannelUseCase.getRSSChannelResult = .success(Mock.updatedChannel1WithoutItems)
        // When
        await sut.didInitiateRefresh()
        // Then
        XCTAssertEqual(sut.title, "updated title")
        XCTAssertEqual(sut.status, .empty(text: "rss_details_no_items".localizedOrRandom))
    }
    
    @MainActor func test_loadRSSChannel_givenLoadChannelFails_thenUsesCurrentChannel_thenDoesntSetErrorStatus() async throws {
        // Given
        getRSSChannelUseCase.getRSSChannelResult = .failure(Mock.channelError)
        // When
        await sut.didInitiateRefresh()
        // Then
        XCTAssertEqual(sut.title, "channel1")
        XCTAssertEqual(sut.status.isLoaded, true)
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
}



