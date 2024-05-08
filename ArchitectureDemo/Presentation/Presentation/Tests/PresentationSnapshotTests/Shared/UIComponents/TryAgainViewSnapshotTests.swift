//
//  TryAgainViewSnapshotTests.swift
//  
//
//  Created by Danijel Huis on 07.05.2024..
//

import XCTest
import SnapshotTesting
import SwiftUI
@testable import Presentation

final class TryAgainViewSnapshotTests: XCTestCase {
    func test_tryAgainView() throws {
        assertSnapshot(of: host(ContainerView()), as: .image(size: CGSize(width: 300, height: 400)))
    }
}

private struct ContainerView: View {
    var body: some View {
        VStack(spacing: 20) {
            TryAgainView(text: "short", tryAgainText: "short", tryAgainClosure: nil)
            TryAgainView(text: "long long long long long long long long", tryAgainText: "long long long long long long long long", tryAgainClosure: nil)
        }
    }
}
