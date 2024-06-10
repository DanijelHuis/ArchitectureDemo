//
//  RSSManagerTests.swift
//
//
//  Created by Danijel Huis on 20.05.2024..
//

import XCTest
import Combine
import TestUtility
@testable import Domain

final class RSSManagerTests: XCTestCase {
    private var historyRepository: MockRSSHistoryRepository!
    private var rssRepository: MockRSSRepository!
    private var sut: RSSManager!
    private var outputCalls = [[RSSChannelResponse]]()
    private var cancellables: Set<AnyCancellable> = []
    
    private struct Mock {
        static let error = MockError.generalError("error 1")
        static let url = URL(string: "https://url1")!
        static let item1 = RSSHistoryItem.mock()
        static let item2 = RSSHistoryItem.mock()
        static let item3 = RSSHistoryItem.mock()
        static let channel1 = RSSChannel.mock()
        static let channel2 = RSSChannel.mock()
        static let channel3 = RSSChannel.mock()
        static let items = [item1, item2, item3]
        static let channels = [
            RSSChannelResponse(historyItem: item1, channel: .success(channel1)),
            RSSChannelResponse(historyItem: item2, channel: .success(channel2)),
            RSSChannelResponse(historyItem: item3, channel: .success(channel3))
        ]
        static let channelsResponse: [UUID: Result<RSSChannel, RSSChannelError>] = [item1.id: .success(channel1), item2.id: .success(channel2), item3.id: .success(channel3)]
    }
    
    override func setUp() {
        historyRepository = .init()
        rssRepository = .init()
        sut = .init(historyRepository: historyRepository, rssRepository: rssRepository)
        
        sut.output.sink { [weak self] channels in
            self?.outputCalls.append(channels)
        }.store(in: &cancellables)
    }
    
    override func tearDown() {
        historyRepository = nil
        rssRepository = nil
        sut = nil
    }
    
    // The purpose of this is to set channelsCache, that way we can test if channels were force-reloaded or not.
    private func loadInitialChannels() async throws {
        historyRepository.getRSSHistoryItemsResult = .success(Mock.items)
        rssRepository.getRSSChannelsResult = Mock.channelsResponse
        try await sut.getRSSChannels()
        outputCalls.removeAll()
        
        // Resetting default mock values
        historyRepository.getRSSHistoryItemsResult = .failure(MockError.mockNotSetup)
        rssRepository.getRSSChannelsResult.removeAll()
        rssRepository.getRSSChannelsCalls.removeAll()
    }
    
    // MARK: - getRSSHistoryItems -
    
    func test_getRSSChannels_givenSuccess_thenEmitsCorrectChannels() async throws {
        // Given
        try await loadInitialChannels()
        historyRepository.getRSSHistoryItemsResult = .success(Mock.items)
        rssRepository.getRSSChannelsResult = Mock.channelsResponse;
        // When
        try await sut.getRSSChannels()
        // Then: Reloads channels
        XCTAssertEqual(rssRepository.getRSSChannelsCalls.count, 1)
        // Then: outputs correct channels
        XCTAssertEqual(outputCalls, [Mock.channels])
    }
    
    func test_getRSSChannels_givenSuccess_givenSomeItemsMissing_thenReturnsNilResultForMissingItems() async throws {
        // Given
        try await loadInitialChannels()
        historyRepository.getRSSHistoryItemsResult = .success(Mock.items)
        rssRepository.getRSSChannelsResult = [Mock.item3.id: .success(Mock.channel3)];
        // When
        try await sut.getRSSChannels()
        // Then: Reloads channels
        XCTAssertEqual(rssRepository.getRSSChannelsCalls.count, 1)
        // Then: outputs correct channels
        XCTAssertEqual(outputCalls, [[
            RSSChannelResponse(historyItem: Mock.item1, channel: nil),
            RSSChannelResponse(historyItem: Mock.item2, channel: nil),
            RSSChannelResponse(historyItem: Mock.item3, channel: .success(Mock.channel3))
        ]]
        )
    }
    
    func test_getRSSChannels_givenFailure_thenThrows() async throws {
        // Given
        historyRepository.getRSSHistoryItemsResult = .failure(Mock.error)
        // Then
        await XCTAssertError(Mock.error) {
            // When
            try await sut.getRSSChannels()
        }
    }
    
    // MARK: - addRSSHistoryItem -
    
    func test_addRSSHistoryItem_givenSuccess_thenAddsItemAndEmitsCorrectChannels() async throws {
        // Given
        try await loadInitialChannels()
        historyRepository.addRSSHistoryItemResult = .success(Mock.items)
        rssRepository.getRSSChannelsResult = Mock.channelsResponse;
        // When
        try await sut.addRSSHistoryItem(channelURL: Mock.url)
        // Then: sends correct parameters to repository
        XCTAssertEqual(historyRepository.addRSSHistoryItemCalls.count, 1)
        XCTAssertEqual(historyRepository.addRSSHistoryItemCalls.first?.channelURL, Mock.url)
        // Then: Reloads channels
        XCTAssertEqual(rssRepository.getRSSChannelsCalls.count, 1)
        // Then: outputs correct channels
        XCTAssertEqual(outputCalls, [Mock.channels])
    }
    
    func test_addRSSHistoryItem_givenFailure_thenThrows() async throws {
        // Given
        try await loadInitialChannels()
        historyRepository.addRSSHistoryItemResult = .failure(Mock.error)
        rssRepository.getRSSChannelsResult = Mock.channelsResponse;
        // Then
        await XCTAssertError(Mock.error) {
            // When
            try await sut.addRSSHistoryItem(channelURL: Mock.url)
        }
    }
    
    // MARK: - removeRSSHistoryItem -
    
    func test_removeRSSHistoryItem_givenSuccess_thenRemovesItemAndEmitsCorrectChannels() async throws {
        // Given
        try await loadInitialChannels()
        let uuid = UUID()
        historyRepository.removeRSSHistoryItemResult = .success(Mock.items)
        rssRepository.getRSSChannelsResult = Mock.channelsResponse;
        // When
        try await sut.removeRSSHistoryItem(uuid)
        // Then: sends correct parameters to repository
        XCTAssertEqual(historyRepository.removeRSSHistoryItemCalls.count, 1)
        XCTAssertEqual(historyRepository.removeRSSHistoryItemCalls.first, uuid)
        // Then: Doesn't reload channels
        XCTAssertEqual(rssRepository.getRSSChannelsCalls.count, 0)
        // Then: outputs correct channels
        XCTAssertEqual(outputCalls, [Mock.channels])
    }
    
    func test_removeRSSHistoryItem_givenFailure_thenThrows() async throws {
        // Given
        let uuid = UUID()
        historyRepository.removeRSSHistoryItemResult = .failure(Mock.error)
        rssRepository.getRSSChannelsResult = Mock.channelsResponse;
        // Then
        await XCTAssertError(Mock.error) {
            // When
            try await sut.removeRSSHistoryItem(uuid)
        }
    }
    
    // MARK: - changeFavouriteStatus -
    
    func test_changeFavouriteStatus_givenSuccess_thenChangesFavouriteStateAndEmitsCorrectChannels() async throws {
        // Given
        try await loadInitialChannels()
        let item = Mock.item2
        historyRepository.getRSSHistoryItemResult = .success(item)
        historyRepository.updateRSSHistoryItemResult = .success(Mock.items)
        rssRepository.getRSSChannelsResult = Mock.channelsResponse;
        // When
        try await sut.changeFavouriteStatus(historyItemID: item.id, isFavourite: true)
        // Then: request correct item
        XCTAssertEqual(historyRepository.getRSSHistoryItemCalls.count, 1)
        XCTAssertEqual(historyRepository.getRSSHistoryItemCalls.first, item.id)
        // Then: updates correct item and sets favourite
        XCTAssertEqual(historyRepository.updateRSSHistoryItemCalls.count, 1)
        XCTAssertEqual(historyRepository.updateRSSHistoryItemCalls.first?.id, item.id)
        XCTAssertEqual(historyRepository.updateRSSHistoryItemCalls.first?.isFavourite, true)
        // Then: Doesn't reload channels
        XCTAssertEqual(rssRepository.getRSSChannelsCalls.count, 0)
        // Then: outputs correct channels
        XCTAssertEqual(outputCalls, [Mock.channels])
    }
    
    func test_changeFavouriteStatus_givenGetRSSHistoryItemFailure_thenThrows() async throws {
        // Given
        try await loadInitialChannels()
        let item = Mock.item2
        historyRepository.getRSSHistoryItemResult = .failure(Mock.error)
        historyRepository.updateRSSHistoryItemResult = .success(Mock.items)
        // Then
        await XCTAssertError(Mock.error) {
            // When
            try await sut.changeFavouriteStatus(historyItemID: item.id, isFavourite: true)
        }
    }
    
    func test_changeFavouriteStatus_givenUpdateRSSHistoryItemFailure_thenThrows() async throws {
        // Given
        try await loadInitialChannels()
        let item = Mock.item2
        historyRepository.getRSSHistoryItemResult = .success(item)
        historyRepository.updateRSSHistoryItemResult = .failure(Mock.error)
        // Then
        await XCTAssertError(Mock.error) {
            // When
            try await sut.changeFavouriteStatus(historyItemID: item.id, isFavourite: true)
        }
    }
}

