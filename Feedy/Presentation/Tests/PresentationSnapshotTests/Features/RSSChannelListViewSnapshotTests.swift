//
//  RSSChannelListViewSnapshotTests.swift
//
//
//  Created by Danijel Huis on 20.05.2024..
//

import XCTest
import SnapshotTesting
import SwiftUI
import Domain
@testable import Presentation

final class RSSChannelListViewSnapshotTests: XCTestCase {
    @MainActor func test_rssListView_givenEmptyStatus() throws {
        let state = RSSChannelListViewModel.State(isShowingFavourites: false, historyItems: [], rssChannels: [:])
        let viewModel = MockSwiftUIViewModelOf<RSSChannelListViewModel>(state: state)
        let view = RSSChannelListView(viewModel: .init(viewModel: viewModel))
        assertSnapshot(of: host(view), as: .image(size: CGSize(width: 400, height: 600)))
    }
    
    @MainActor func test_rssListView_givenLoadingStatus() throws {
        var state = RSSChannelListViewModel.State(isShowingFavourites: false, historyItems: [], rssChannels: [:])
        state.isLoading = true;
        let viewModel = MockSwiftUIViewModelOf<RSSChannelListViewModel>(state: state)
        let view = RSSChannelListView(viewModel: .init(viewModel: viewModel))
        assertSnapshot(of: host(view), as: .image(size: CGSize(width: 400, height: 600)))
    }
    
    @MainActor func test_rssListView_givenErrorStatus() throws {
        var state = RSSChannelListViewModel.State(isShowingFavourites: false, historyItems: [], rssChannels: [:])
        state.didFail = true
        let viewModel = MockSwiftUIViewModelOf<RSSChannelListViewModel>(state: state)
        let view = RSSChannelListView(viewModel: .init(viewModel: viewModel))
        assertSnapshot(of: host(view), as: .image(size: CGSize(width: 400, height: 600)))
    }
    
    @MainActor func test_rssListView_givenLoadedStatus() throws {
        let uuid1 = UUID()
        let uuid2 = UUID()
        let historyItem1 = RSSHistoryItem(id: uuid1, channelURL: URL(string: "test")!, isFavourite: true, lastReadItemID: nil)
        let historyItem2 = RSSHistoryItem(id: uuid2, channelURL: URL(string: "test")!, isFavourite: true, lastReadItemID: nil)
        let channel1 = RSSChannel(title: .loremIpsumShort, description: .loremIpsumShort, imageURL: nil, items: [])
        let channel2 = RSSChannel(title: .loremIpsumMedium, description: .loremIpsumMedium, imageURL: nil, items: [])

        let state = RSSChannelListViewModel.State(isShowingFavourites: false, historyItems: [historyItem1, historyItem2],
                                                  rssChannels: [uuid1: .success(channel1), uuid2: .success(channel2)])
        let viewModel = MockSwiftUIViewModelOf<RSSChannelListViewModel>(state: state)
        let view = RSSChannelListView(viewModel: .init(viewModel: viewModel))
        assertSnapshot(of: host(view), as: .image(size: CGSize(width: 400, height: 600)))
    }
}
