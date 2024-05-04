//
//  Container.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation
import Domain
import Data

/// Poor man's dependency injection.
struct Container {
    static var getPokemonsUseCase: DefaultGetPokemonsUseCase {
        DefaultGetPokemonsUseCase(pokemonRepository: DefaultPokemonRepository(httpClient: API.Poke.client), pageSize: 50)
    }
    
    static var getPokemonDetailsUseCase: DefaultGetPokemonDetailsUseCase {
        DefaultGetPokemonDetailsUseCase(pokemonRepository: DefaultPokemonRepository(httpClient: API.Poke.client))
    }
}
