//
//  MockGetPokemonDetailsUseCase.swift
//
//
//  Created by Danijel Huis on 05.05.2024..
//

import Foundation
import Domain
import TestUtility
@testable import Presentation

final class MockGetPokemonDetailsUseCase: GetPokemonDetailsUseCase {
    var getPokemonDetails = [String]()
    var getPokemonDetailsResult: Result<PokemonDetails, Error> = .failure(MockError.mockNotSetup)
    func getPokemonDetails(id: String) async throws -> PokemonDetails {
        getPokemonDetails.append(id)
        return try getPokemonDetailsResult.get()
    }
}
