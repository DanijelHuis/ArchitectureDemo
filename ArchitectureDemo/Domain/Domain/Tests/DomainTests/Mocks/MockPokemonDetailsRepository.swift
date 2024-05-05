//
//  MockPokemonDetailsRepository.swift
//  
//
//  Created by Danijel Huis on 05.05.2024..
//

@testable import Domain
import TestUtility

final class MockPokemonDetailsRepository: PokemonDetailsRepository {    
    var getPokemonDetailsCalls = [String]()
    var getPokemonDetailsResult: Result<PokemonDetails, Error> = .failure(MockError.mockNotSetup)
    func getPokemonDetails(id: String) async throws -> Domain.PokemonDetails {
        getPokemonDetailsCalls.append(id)
        return try getPokemonDetailsResult.get()
    }
}
