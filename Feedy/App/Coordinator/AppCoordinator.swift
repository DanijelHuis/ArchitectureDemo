//
//  AppCoordinator.swift
//  Feedy
//
//  Created by Danijel Huis on 18.05.2024..
//

import Foundation
import SwiftUI
import Presentation

/// Every view is supposed to create its own instance of AppCoordinator, that way if something needs to be persisted in child coordinator, its lifecycle will be tied to the view.
@MainActor struct AppCoordinator: Coordinator {
    let navigator: Navigator
    let rssCoordinator = RSSCoordinator()
    let commonCoordinator = CommonCoordinator()
    
    init(navigator: Navigator) {
        self.navigator = navigator
    }
    
    func openRoute(_ route: AppRoute) {
        let routeResult = view(route)
        switch routeResult {
        case .push(let view):
            navigator.push(route, view: view)
        case .present(let controller, let animated):
            navigator.present(route, controller: controller, animated: animated)
        case .none:
            break
        }
    }
    
    func view(_ route: AppRoute) -> RouteResult {
        switch route {
        case .rss(let route):
            rssCoordinator.view(route, navigator: navigator)
        case .common(let route):
            commonCoordinator.view(route, navigator: navigator)
        }
    }
}
