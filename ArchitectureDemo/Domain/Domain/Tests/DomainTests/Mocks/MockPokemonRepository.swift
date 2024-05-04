//
//  MockPokemonRepository.swift
//
//
//  Created by Danijel Huis on 04.05.2024..
//

@testable import Domain
import TestUtility

class MockPokemonRepository: PokemonRepository {
    var getPokemonsPageCalls = [(offset: Int, limit: Int)]()
    var getPokemonsPageResult: Result<PokemonsPage, Error> = .failure(MockError.mockNotSetup)
    func getPokemonsPage(offset: Int, limit: Int) async throws -> Domain.PokemonsPage {
        getPokemonsPageCalls.append((offset, limit))
        return try getPokemonsPageResult.get()
    }
    
    var getPokemonDetailsCalls = [String]()
    var getPokemonDetailsResult: Result<PokemonDetails, Error> = .failure(MockError.mockNotSetup)
    func getPokemonDetails(id: String) async throws -> Domain.PokemonDetails {
        getPokemonDetailsCalls.append(id)
        return try getPokemonDetailsResult.get()
    }
}
