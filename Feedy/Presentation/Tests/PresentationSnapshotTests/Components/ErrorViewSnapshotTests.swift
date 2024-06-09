//
//  ErrorViewSnapshotTests.swift
//
//
//  Created by Danijel Huis on 20.05.2024..
//

import XCTest
import SnapshotTesting
import SwiftUI
@testable import CommonUI

final class ErrorViewSnapshotTests: XCTestCase {
    @MainActor func test_errorView() throws {
        assertSnapshot(of: host(ContainerView()), as: .image(size: CGSize(width: 300, height: 400)))
    }
}

private struct ContainerView: View {
    var body: some View {
        VStack(spacing: 20) {
            ErrorView(text: .loremIpsumShort)
            ErrorView(text: .loremIpsumMedium)
        }
    }
}
