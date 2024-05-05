//
//  MockPokemonListRepository.swift
//
//
//  Created by Danijel Huis on 04.05.2024..
//

@testable import Domain
import TestUtility

final class MockPokemonListRepository: PokemonListRepository {
    var getPokemonsPageCalls = [(offset: Int, limit: Int)]()
    var getPokemonsPageResult: Result<PokemonsPage, Error> = .failure(MockError.mockNotSetup)
    func getPokemonsPage(offset: Int, limit: Int) async throws -> Domain.PokemonsPage {
        getPokemonsPageCalls.append((offset, limit))
        return try getPokemonsPageResult.get()
    }
}
