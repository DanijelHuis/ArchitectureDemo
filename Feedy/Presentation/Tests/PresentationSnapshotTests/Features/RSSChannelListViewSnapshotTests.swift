//
//  RSSChannelListViewSnapshotTests.swift
//
//
//  Created by Danijel Huis on 20.05.2024..
//

import XCTest
import SnapshotTesting
import SwiftUI
@testable import Presentation

final class RSSChannelListViewSnapshotTests: XCTestCase {
    @MainActor func test_rssListView_givenEmptyStatus() throws {
        let state = RSSChannelListViewModel.State(isShowingFavourites: false, status: .empty(text: .loremIpsumMedium))
        let viewModel = MockSwiftUIViewModelOf<RSSChannelListViewModel>(state: state)
        let view = RSSChannelListView(viewModel: .init(viewModel: viewModel))
        assertSnapshot(of: host(view), as: .image(size: CGSize(width: 400, height: 600)))
    }
    
    @MainActor func test_rssListView_givenLoadingStatus() throws {
        let state = RSSChannelListViewModel.State(isShowingFavourites: false, status: .loading(text: .loremIpsumMedium))
        let viewModel = MockSwiftUIViewModelOf<RSSChannelListViewModel>(state: state)
        let view = RSSChannelListView(viewModel: .init(viewModel: viewModel))
        assertSnapshot(of: host(view), as: .image(size: CGSize(width: 400, height: 600)))
    }
    
    @MainActor func test_rssListView_givenErrorStatus() throws {
        let state = RSSChannelListViewModel.State(isShowingFavourites: false, status: .error(text: .loremIpsumMedium))
        let viewModel = MockSwiftUIViewModelOf<RSSChannelListViewModel>(state: state)
        let view = RSSChannelListView(viewModel: .init(viewModel: viewModel))
        assertSnapshot(of: host(view), as: .image(size: CGSize(width: 400, height: 600)))
    }
    
    @MainActor func test_rssListView_givenLoadedStatus() throws {
        let status = RSSChannelListViewModel.ViewStatus.loaded(states: [
            .init(historyItemID: UUID(), title: .loremIpsumShort, description: .loremIpsumShort, imageResource: .init(url: nil, placeholderSystemName: "newspaper"), isFavourite: true),
            .init(historyItemID: UUID(), title: .loremIpsumMedium, description: .loremIpsumMedium, imageResource: .init(url: nil, placeholderSystemName: "newspaper"), isFavourite: true)
        ])
        
        let state = RSSChannelListViewModel.State(isShowingFavourites: false, status: status)
        let viewModel = MockSwiftUIViewModelOf<RSSChannelListViewModel>(state: state)
        let view = RSSChannelListView(viewModel: .init(viewModel: viewModel))
        assertSnapshot(of: host(view), as: .image(size: CGSize(width: 400, height: 600)))
    }
}
