//
//  RSSChannelDetailsViewSnapshotTests.swift
//
//
//  Created by Danijel Huis on 20.05.2024..
//

import XCTest
import SnapshotTesting
import SwiftUI
@testable import Domain
@testable import Presentation

final class RSSChannelDetailsViewSnapshotTests: XCTestCase {
    
    override func setUp() {
        Container.locale = Locale(identifier: "en")
        Container.timeZone = TimeZone(secondsFromGMT: 0)!
    }
    
    @MainActor func test_rssDetailsView_givenEmptyStatus() throws {
        var state = RSSChannelDetailsViewModel.State(rssHistoryItem: .mock(), rssChannel: .mock(items: []))
        state.isLoading = false
        let viewModel = MockSwiftUIViewModelOf<RSSChannelDetailsViewModel>(state: state)
        let view = RSSChannelDetailsView(viewModel: .init(viewModel: viewModel))
        assertSnapshot(of: host(view), as: .image(size: CGSize(width: 400, height: 600)))
    }
    
    @MainActor func test_rssDetailsView_givenLoadingStatus() throws {
        var state = RSSChannelDetailsViewModel.State(rssHistoryItem: .mock(), rssChannel: .mock(items: []))
        state.isLoading = true
        let viewModel = MockSwiftUIViewModelOf<RSSChannelDetailsViewModel>(state: state)
        let view = RSSChannelDetailsView(viewModel: .init(viewModel: viewModel))
        assertSnapshot(of: host(view), as: .image(size: CGSize(width: 400, height: 600)))
    }

    @MainActor func test_rssDetailsView_givenLoadedStatus() throws {
        let date = Date(timeIntervalSince1970: 0)
        let item1 = RSSItem.mock(guid: "1", title: .loremIpsumShort, description: .loremIpsumShort, imageURL: nil,  pubDate: date)
        let item2 = RSSItem.mock(guid: "2", title: .loremIpsumMedium, description: .loremIpsumMedium, imageURL: nil, pubDate: date)
        let item3 = RSSItem.mock(guid: "3", title: .loremIpsumMedium, description: nil, imageURL: nil, pubDate: date)
        let item4 = RSSItem.mock(guid: "4", title: nil, description: .loremIpsumMedium, imageURL: nil, pubDate: date)

        var state = RSSChannelDetailsViewModel.State(rssHistoryItem: .mock(), rssChannel: .mock(items: [item1, item2, item3, item4]))
        state.isLoading = false
        let viewModel = MockSwiftUIViewModelOf<RSSChannelDetailsViewModel>(state: state)
        let view = RSSChannelDetailsView(viewModel: .init(viewModel: viewModel))
        assertSnapshot(of: host(view), as: .image(size: CGSize(width: 400, height: 600)))
    }
}


