//
//  GetPokemonDetailsUseCase.swift
//
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation

public protocol GetPokemonDetailsUseCaseProtocol {
    func getPokemonDetails(id: String) async throws -> PokemonDetails
}

public final class GetPokemonDetailsUseCase: GetPokemonDetailsUseCaseProtocol {
    private let pokemonRepository: PokemonRepositoryProtocol
    
    public init(pokemonRepository: PokemonRepositoryProtocol) {
        self.pokemonRepository = pokemonRepository
    }
    
    public func getPokemonDetails(id: String) async throws -> PokemonDetails {
        try await pokemonRepository.getPokemonDetails(id: id)
    }
}
