//
//  AppCoordinatorProtocol.swift
//
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation

// MARK: - Routes -

/// AppRoute contains all routes in the app. For scalability we separate it into sub-routes.
public enum AppRoute {
    case pokemons(_ route: PokemonsRoute)
}

public enum PokemonsRoute {
    case list
    case details(id: String)
}

// MARK: - AppCoordinatorProtocol -

@MainActor public protocol AppCoordinatorProtocol {
    func openRoute(_ route: AppRoute)
}
