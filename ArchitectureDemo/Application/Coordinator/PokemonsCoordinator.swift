//
//  PokemonsCoordinator.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation
import Presentation
import Domain
import SwiftUI
import Uniflow

@MainActor struct PokemonsCoordinator {
    func view(_ route: PokemonsRoute, navigator: Navigator) -> any View {
        switch route {
            
        case .list:
            let viewModel = Store(
                state: PokemonListViewModel.State.idle,
                reducer: PokemonListViewModel(getPokemonListUseCase: Container.getPokemonListUseCase,
                                              coordinator: AppCoordinator(navigator: navigator))
            )
            return PokemonListView(viewModel: viewModel)
            
        case .details(let id):
            let viewModel = Store(
                state: PokemonDetailsViewModel.State.idle,
                reducer: PokemonDetailsViewModel(pokemonID: id,
                                                 getPokemonDetailsUseCase: Container.getPokemonDetailsUseCase,
                                                 coordinator: AppCoordinator(navigator: navigator))
            )
            return PokemonDetailsView(viewModel: viewModel)
        }
    }
}
