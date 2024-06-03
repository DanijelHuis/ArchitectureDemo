//
//  MainView.swift
//  Feedy
//
//  Created by Danijel Huis on 18.05.2024..
//

import SwiftUI

@MainActor public struct MainView: View {
    @State private var navigator: Navigator
    @State private var rootView: any View
    
    public init(navigator: Navigator, rootView: any View) {
        self.navigator = navigator
        self.rootView = rootView
    }
    
    public var body: some View {
        AppNavigationStack(navigator: navigator) {
            AnyView(rootView)
        }
    }
}
