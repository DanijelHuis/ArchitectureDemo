//
//  DefaultGetPokemonDetailsUseCaseTests.swift
//
//
//  Created by Danijel Huis on 05.05.2024..
//

import XCTest
import TestUtility
@testable import Domain

final class DefaultGetPokemonDetailsUseCaseTests: XCTestCase {
    private var pokemonDetailsRepository: MockPokemonDetailsRepository!
    private var sut: DefaultGetPokemonDetailsUseCase!
    private var pageSize = 3
    
    private struct Mock {
        static let response = PokemonDetails(id: 10, name: "Pokemon10", weight: 1, height: 2, order: 3, types: ["type1", "type2"], imageURL: URL(string: "sprite"))
    }
    
    override func setUp() {
        pokemonDetailsRepository = .init()
        sut = .init(pokemonDetailsRepository: pokemonDetailsRepository)
    }
    
    override func tearDown() {
        pokemonDetailsRepository = nil
        sut = nil
    }
    
    func test_getPokemonDetails_whenRepositorySucceeds_thenReturnsPokemonDetails() async throws {
        // Given
        let pokemonDetails = Mock.response
        pokemonDetailsRepository.getPokemonDetailsResult = .success(pokemonDetails)
        // When
        let result = try await sut.getPokemonDetails(id: "10")
        // Then
        XCTAssertEqual(result, pokemonDetails)
    }
    
    func test_getPokemonDetails_whenRepositoryFails_thenThrowsError() async {
        // Given
        let repositoryError = MockError.generalError("getPokemonDetails error")
        pokemonDetailsRepository.getPokemonDetailsResult = .failure(repositoryError)
        // When
        do {
            _ = try await sut.getPokemonDetails(id: "10")
            XCTFail("Error expected")
        } catch {
            XCTAssertEqual(error as? MockError, repositoryError)
        }
    }
}
