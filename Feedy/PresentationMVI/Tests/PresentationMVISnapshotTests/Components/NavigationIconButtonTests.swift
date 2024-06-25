//
//  NavigationIconButtonTests.swift
//  
//
//  Created by Danijel Huis on 20.05.2024..
//

import XCTest
import SnapshotTesting
import SwiftUI
@testable import CommonUI

final class NavigationIconButtonTests: XCTestCase {
    @MainActor func test_navigationIconButton() throws {
        assertSnapshot(of: host(ContainerView()), as: .image(size: CGSize(width: 80, height: 80)))
    }
}

private struct ContainerView: View {
    var body: some View {
        VStack(spacing: 20) {
            NavigationIconButton(iconSystemName: "folder.fill", action: {})
        }
    }
}
