//
//  PokemonDetailsViewModel.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation
import Domain
import Uniflow

public class PokemonDetailsViewModel: Reducer {
    private let pokemonID: String
    private let getPokemonDetailsUseCase: GetPokemonDetailsUseCase
    private let stateMapper: LoadedStateMapper
    
    public init(pokemonID: String, getPokemonDetailsUseCase: GetPokemonDetailsUseCase,
                stateMapper: LoadedStateMapper = DefaultLoadedStateMapper()) {
        self.pokemonID = pokemonID
        self.getPokemonDetailsUseCase = getPokemonDetailsUseCase
        self.stateMapper = stateMapper
    }
    
    public func reduce(action: Action, into state: inout State) -> Effect<Action, InternalAction, Output> {
        switch action {
        case .getPokemonDetails:
            state = .loading()
            return .run { send in
                do {
                    let pokemonDetails = try await self.getPokemonDetailsUseCase.getPokemonDetails(id: self.pokemonID)
                    await send(.internalAction(.didGetPokemonDetails(pokemonDetails)))
                } catch {
                    await send(.internalAction(.errorOccurred))
                }
            }
        }
    }
    
    public func reduce(internalAction: InternalAction, into state: inout State) -> Effect<Action, InternalAction, Never> {
        switch internalAction {
        case .didGetPokemonDetails(let pokemonDetails):
            state = .loaded(pokemonDetails: stateMapper.map(pokemonDetails: pokemonDetails))
        case .errorOccurred:
            state = .error
        }
        
        return .none
    }
}

// MARK: - State & Action -

extension PokemonDetailsViewModel {
    public enum State: Equatable {
        case idle
        case loading(text: String = "common_loading_wait".localized)
        case error
        case loaded(pokemonDetails: LoadedState)
    }
    
    public struct LoadedState: Equatable {
        var name: String
        var imageURL: URL?
        var height: String
        var weight: String
        var order: String
        var type: String
    }
    
    public enum Action {
        case getPokemonDetails
    }
    
    public enum InternalAction {
        case didGetPokemonDetails(_ pokemonDetails: PokemonDetails)
        case errorOccurred
    }
}


