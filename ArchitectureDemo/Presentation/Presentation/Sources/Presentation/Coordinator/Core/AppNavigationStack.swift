//
//  AppNavigationStack.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation
import SwiftUI

/// NavigationStack that can open any AppRoute.
struct AppNavigationStack<Root: View>: View {
    @ObservedObject private var navigator: Navigator
    private let root: Root
    
    init(navigator: Navigator, @ViewBuilder root: () -> Root) {
        self.navigator = navigator
        self.root = root()
    }
    
    var body: some View {
        NavigationStack(path: $navigator.path) {
            root
                .navigationDestination(for: NavigationDestination.self) { destination in
                    // We are using AnyView because it is difficult to carry "some View" across modules. Performance penalty shouldn't be big compared to
                    // big @ViewBuild tree that we would have in AppCoordinator if we were using one coordinator for whole app. The main goal is to have one class
                    // that can handle all navigation destinations so we don't have to worry about missing .navigationDestination for some route.
                    AnyView(destination.view)
                }
        }
    }
}
