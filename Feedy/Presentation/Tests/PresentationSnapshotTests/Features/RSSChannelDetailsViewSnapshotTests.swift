//
//  RSSChannelDetailsViewSnapshotTests.swift
//
//
//  Created by Danijel Huis on 20.05.2024..
//

import XCTest
import SnapshotTesting
import SwiftUI
@testable import Presentation

final class RSSChannelDetailsViewSnapshotTests: XCTestCase {
    @MainActor func test_rssDetailsView_givenEmptyStatus() throws {
        let state = RSSChannelDetailsViewModel.State(title: .loremIpsumShort, 
                                                     isFavourite: true,
                                                     status: .empty(text: .loremIpsumMedium))
        let viewModel = MockSwiftUIViewModelOf<RSSChannelDetailsViewModel>(state: state)
        let view = RSSChannelDetailsView(viewModel: .init(viewModel: viewModel))
        assertSnapshot(of: host(view), as: .image(size: CGSize(width: 400, height: 600)))
    }
    
    @MainActor func test_rssDetailsView_givenLoadingStatus() throws {
        let state = RSSChannelDetailsViewModel.State(title: .loremIpsumShort,
                                                     isFavourite: true,
                                                     status: .loading(text: .loremIpsumMedium))
        let viewModel = MockSwiftUIViewModelOf<RSSChannelDetailsViewModel>(state: state)
        let view = RSSChannelDetailsView(viewModel: .init(viewModel: viewModel))
        assertSnapshot(of: host(view), as: .image(size: CGSize(width: 400, height: 600)))
    }
    
    @MainActor func test_rssDetailsView_givenLoadedStatus() throws {
        let loadedStatus = RSSChannelDetailsViewModel.ViewStatus.loaded(states: [
            .init(id: "1", link: URL(string:"http://link1"), title: .loremIpsumShort, publishDate: "date", description: .loremIpsumShort, imageURL: nil),
            .init(id: "2",
                  link: URL(string:"http://link2"),
                  title: .loremIpsumMedium,
                  publishDate: "date",
                  description: .loremIpsumMedium,
                  imageURL: nil),
            .init(id: "3", link: URL(string:"http://link3"), title: .loremIpsumMedium, publishDate: nil, description: nil, imageURL: nil),
            .init(id: "3", link: URL(string:"http://link3"), title: nil, publishDate: "date", description: .loremIpsumMedium, imageURL: nil)

        ])
        
        let state = RSSChannelDetailsViewModel.State(title: "Details",
                                                     isFavourite: true,
                                                     status: loadedStatus)
        let viewModel = MockSwiftUIViewModelOf<RSSChannelDetailsViewModel>(state: state)
        let view = RSSChannelDetailsView(viewModel: .init(viewModel: viewModel))
        assertSnapshot(of: host(view), as: .image(size: CGSize(width: 400, height: 600)))
    }
}

