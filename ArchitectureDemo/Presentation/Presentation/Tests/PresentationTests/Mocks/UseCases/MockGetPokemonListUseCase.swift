//
//  MockGetPokemonListUseCase.swift
//
//
//  Created by Danijel Huis on 05.05.2024..
//

import Foundation
import Domain
import TestUtility
@testable import Presentation

final class MockGetPokemonListUseCase: GetPokemonListUseCase {
    var getPokemonsNextPageCalls = 0
    var getPokemonsNextPageResult: Result<[Pokemon], Error> = .failure(MockError.mockNotSetup)
    
    func getPokemonsNextPage() async throws -> [Pokemon] {
        getPokemonsNextPageCalls += 1
        return try getPokemonsNextPageResult.get()
    }
    
    var removeAllPagesCalls = 0
    func removeAllPages() {
        removeAllPagesCalls += 1
    }
    
    var hasNextPage: Bool = false
}
