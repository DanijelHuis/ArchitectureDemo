//
//  PokemonListViewModel.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation
import Domain
import Uniflow

public final class PokemonListViewModel: Reducer {
    private let getPokemonsUseCase: GetPokemonsUseCase
    private let coordinator: Coordinator
    
    public init(getPokemonsUseCase: GetPokemonsUseCase, coordinator: Coordinator) {
        self.getPokemonsUseCase = getPokemonsUseCase
        self.coordinator = coordinator
    }
    
    public func reduce(action: Action, into state: inout State) -> Effect<Action, InternalAction, Never> {
        switch action {
        case .loadNextPage:
            // If it is in loaded state then we don't need to show loading because load more is shown.
            if !state.isLoaded { state = .loading() }
            return .run { send in
                // Fetch next page
                do {
                    let pokemons = try await self.getPokemonsUseCase.getPokemonsNextPage()
                    await send(.internalAction(.didGetPokemons(pokemons: pokemons, hasMoreItems: self.getPokemonsUseCase.hasNextPage)))
                } catch {
                    await send(.internalAction(.errorOccurred))
                }
            }
            
        case .openDetails(let id):
            coordinator.openRoute(.pokemons(.details(id: id)))
        }
        
        return .none
    }
    
    public func reduce(internalAction: InternalAction, into state: inout State) -> Effect<Action, InternalAction, Never> {
        switch internalAction {
        case .didGetPokemons(let pokemons, let hasMoreItems):
            state = .loaded(items: pokemons.map({ .init(id: $0.id, name: $0.name) }), hasMoreItems: hasMoreItems)
        case .errorOccurred:
            state = .error
        }
        
        return .none
    }
}

// MARK: - State & Action -

extension PokemonListViewModel {
    public enum State {
        case idle
        case loading(text: String = "common_loading_wait".localized)
        case loaded(items: [PokemonListItemView.State], hasMoreItems: Bool)
        case error
    }
    
    public enum Action {
        case loadNextPage
        case openDetails(id: String)
    }
    
    public enum InternalAction {
        case didGetPokemons(pokemons: [Pokemon], hasMoreItems: Bool)
        case errorOccurred
    }
}

private extension PokemonListViewModel.State {
    var isLoaded: Bool {
        switch self {
        case .loaded: true
        default: false
        }
    }
}
