//
//  AppCoordinator.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation
import Presentation
import SwiftUI

/// Every view is supposed to create its own instance of AppCoordinator, that way if something needs to be persisted in child coordinator, its lifecycle will be tied to the view.
@MainActor struct AppCoordinator: Coordinator {
    let navigator: Navigator
    let pokemonsCoordinator = PokemonsCoordinator()
    
    func openRoute(_ route: AppRoute) {
        navigator.push(route, view: view(route))
    }
    
    func view(_ route: AppRoute) -> any View {
        switch route {
        case .pokemons(let route):
            pokemonsCoordinator.view(route, navigator: navigator)
        }
    }
}
