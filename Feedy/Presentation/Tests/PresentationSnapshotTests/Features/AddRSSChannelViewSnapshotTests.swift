//
//  AddRSSChannelViewSnapshotTests.swift
//
//
//  Created by Danijel Huis on 20.05.2024..
//

import XCTest
import SnapshotTesting
import SwiftUI
@testable import Presentation

final class AddRSSChannelViewSnapshotTests: XCTestCase {
    @MainActor func test_addRSSChannelView_givenIdleStatus() throws {
        let state = AddRSSChannelViewModel.State(channelURL: "http://feed", status: .idle)
        let viewModel = MockSwiftUIViewModelOf<AddRSSChannelViewModel>(state: state)
        let view = AddRSSChannelView(viewModel: .init(viewModel: viewModel))
        assertSnapshot(of: host(view), as: .image(size: CGSize(width: 400, height: 600)))
    }
    
    @MainActor func test_addRSSChannelView_givenValidatingStatus() throws {
        let state = AddRSSChannelViewModel.State(channelURL: "http://feed", status: .validating)
        let viewModel = MockSwiftUIViewModelOf<AddRSSChannelViewModel>(state: state)
        let view = AddRSSChannelView(viewModel: .init(viewModel: viewModel))
        assertSnapshot(of: host(view), as: .image(size: CGSize(width: 400, height: 600)))
    }
    
    @MainActor func test_addRSSChannelView_givenErrorStatus() throws {
        let state = AddRSSChannelViewModel.State(channelURL: "http://feed", status: .error(message: .loremIpsumMedium))
        let viewModel = MockSwiftUIViewModelOf<AddRSSChannelViewModel>(state: state)
        let view = AddRSSChannelView(viewModel: .init(viewModel: viewModel))
        assertSnapshot(of: host(view), as: .image(size: CGSize(width: 400, height: 600)))
    }
}

