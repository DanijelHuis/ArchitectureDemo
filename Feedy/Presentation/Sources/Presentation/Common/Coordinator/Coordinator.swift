//
//  Coordinator.swift
//
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation
import Domain

// MARK: - Routes -

/// AppRoute contains all routes in the app. For scalability we separate it into sub-routes.
public enum AppRoute: Equatable {
    case rss(_ route: RSSRoute)
    case common(_ route: CommonRoute)
}

public enum RSSRoute: Equatable {
    case list
    case add
    case details(rssHistoryItem: RSSHistoryItem, channel: RSSChannel)
}

public enum CommonRoute: Equatable {
    case safari(url: URL)
}

// MARK: - Main App Coordinator -

@MainActor public protocol Coordinator {
    func openRoute(_ route: AppRoute)
}
