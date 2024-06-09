//
//  EmptyDataViewSnapshotTests.swift
//
//
//  Created by Danijel Huis on 20.05.2024..
//

import XCTest
import SnapshotTesting
import SwiftUI
@testable import CommonUI

final class EmptyDataViewSnapshotTests: XCTestCase {
    @MainActor func test_emptyDataView() throws {
        assertSnapshot(of: host(ContainerView()), as: .image(size: CGSize(width: 300, height: 500)))
    }
}

private struct ContainerView: View {
    var body: some View {
        VStack(spacing: 20) {
            EmptyDataView(text: .loremIpsumShort)
            EmptyDataView(text: .loremIpsumMedium)
        }
    }
}
