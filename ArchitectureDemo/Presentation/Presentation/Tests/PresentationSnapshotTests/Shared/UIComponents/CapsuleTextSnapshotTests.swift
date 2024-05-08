//
//  CapsuleTextSnapshotTests.swift
//
//
//  Created by Danijel Huis on 06.05.2024..
//

import XCTest
import SnapshotTesting
import SwiftUI
@testable import Presentation

final class CapsuleTextSnapshotTests: XCTestCase {
    @MainActor func test_capsuleText() throws {
        assertSnapshot(of: host(ContainerView()), as: .image(size: CGSize(width: 200, height: 100)))
    }
}

private struct ContainerView: View {
    var body: some View {
        VStack(spacing: 20) {
            CapsuleText(text: "short")
            CapsuleText(text: "long long long long long long long")
        }
    }
}
