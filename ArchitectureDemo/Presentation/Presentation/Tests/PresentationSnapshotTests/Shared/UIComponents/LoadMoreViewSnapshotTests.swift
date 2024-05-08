//
//  LoadMoreViewSnapshotTests.swift
//  
//
//  Created by Danijel Huis on 07.05.2024..
//

import XCTest
import SnapshotTesting
import SwiftUI
@testable import Presentation

final class LoadMoreViewSnapshotTests: XCTestCase {
    func test_loadMoreView() throws {
        assertSnapshot(of: host(ContainerView()), as: .image(size: CGSize(width: 200, height: 200)))
    }
}

private struct ContainerView: View {
    var body: some View {
        VStack(spacing: 20) {
            LoadMoreView(text: "short")
            LoadMoreView(text: "long long long long long long long")
        }
    }
}
