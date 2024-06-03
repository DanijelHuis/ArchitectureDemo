//
//  FeedyApp.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import SwiftUI
import XMLCoder
import Presentation
import BackgroundTasks

struct Note: Codable {
    let to: String
    let from: String
    let heading: String
    let body: String
}

struct RSS: Codable {
    let note: Note
}

@main
struct FeedyApp: App {
    private let navigator = Navigator()
    private let rssList: any View
    @Environment(\.scenePhase) private var phase

    init() {
        AppStyle.setupAppStyle()
        switch AppCoordinator(navigator: navigator).view(.rss(.list)) {
        case .push(let view):
            rssList = view
        default:
            rssList = EmptyView()
        }        
    }
    
    var body: some Scene {
        WindowGroup {
            MainView(navigator: navigator, rootView: rssList)
        }
    }
}
