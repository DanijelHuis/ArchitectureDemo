//
//  GetPokemonDetailsUseCase.swift
//
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation

public protocol GetPokemonDetailsUseCase {
    func getPokemonDetails(id: String) async throws -> PokemonDetails
}

public final class DefaultGetPokemonDetailsUseCase: GetPokemonDetailsUseCase {
    private let pokemonRepository: PokemonRepository
    
    public init(pokemonRepository: PokemonRepository) {
        self.pokemonRepository = pokemonRepository
    }
    
    public func getPokemonDetails(id: String) async throws -> PokemonDetails {
        try await pokemonRepository.getPokemonDetails(id: id)
    }
}
