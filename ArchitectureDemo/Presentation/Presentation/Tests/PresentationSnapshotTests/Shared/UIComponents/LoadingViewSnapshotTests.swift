//
//  LoadingViewSnapshotTests.swift
//  
//
//  Created by Danijel Huis on 07.05.2024..
//

import XCTest
import SnapshotTesting
import SwiftUI
@testable import Presentation

final class LoadingViewSnapshotTests: XCTestCase {
    func test_loadingView() throws {
        assertSnapshot(of: host(ContainerView()), as: .image(size: CGSize(width: 200, height: 300)))
    }
}

private struct ContainerView: View {
    var body: some View {
        VStack(spacing: 20) {
            LoadingView(text: "short short")
            LoadingView(text: "long long long long long long long")
        }
    }
}
