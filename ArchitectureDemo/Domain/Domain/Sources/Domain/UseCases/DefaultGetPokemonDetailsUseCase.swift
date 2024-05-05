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
    private let pokemonDetailsRepository: PokemonDetailsRepository
    
    public init(pokemonDetailsRepository: PokemonDetailsRepository) {
        self.pokemonDetailsRepository = pokemonDetailsRepository
    }
    
    public func getPokemonDetails(id: String) async throws -> PokemonDetails {
        try await pokemonDetailsRepository.getPokemonDetails(id: id)
    }
}
