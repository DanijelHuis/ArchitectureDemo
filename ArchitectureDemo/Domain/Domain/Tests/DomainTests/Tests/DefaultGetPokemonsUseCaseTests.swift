//
//  DefaultGetPokemonsUseCaseTests.swift
//
//
//  Created by Danijel Huis on 04.05.2024..
//

import XCTest
@testable import Domain

final class DefaultGetPokemonsUseCaseTests: XCTestCase {
    private var pokemonRepository: MockPokemonRepository!
    private var sut: DefaultGetPokemonsUseCase!
    
    private struct Mock {
        static func pokemons(startIndex: Int, count: Int) -> [Pokemon] {
            Array((startIndex..<startIndex+count)).reduce(into: [Pokemon]()) { partialResult, index in
                partialResult.append(.init(id: "pokemon\(index)", name: "Pokemon\(index))"))
            }
        }
    }
    
    override func setUp() {
        pokemonRepository = .init()
        sut = .init(pokemonRepository: pokemonRepository, pageSize: 3)
    }
    
    func test_getPokemonsNextPage_givenNotCalledBefore_thenRequestsFirstPage_thenReturnsCorrectItems() async throws {
        let pokemons = Mock.pokemons(startIndex: 0, count: 3)
        pokemonRepository.getPokemonsPageResult = .success(.init(count: 10, results: pokemons))
        // When
        let items = try await sut.getPokemonsNextPage()
        // Then
        XCTAssertEqual(pokemonRepository.getPokemonsPageCalls.count, 1)
        XCTAssertEqual(pokemonRepository.getPokemonsPageCalls.first?.offset, 0)
        XCTAssertEqual(pokemonRepository.getPokemonsPageCalls.first?.limit, 3)
        XCTAssertEqual(items, pokemons)
    }
    
    func test_getPokemonsNextPage_givenCalledMultipleTimes_thenReturnsCorrectItems() async throws {
        let pokemons = Mock.pokemons(startIndex: 0, count: 3)
        pokemonRepository.getPokemonsPageResult = .success(.init(count: 10, results: pokemons))
        // When
        let items = try await sut.getPokemonsNextPage()
        // Then
        XCTAssertEqual(pokemonRepository.getPokemonsPageCalls.count, 1)
        XCTAssertEqual(pokemonRepository.getPokemonsPageCalls.first?.offset, 0)
        XCTAssertEqual(pokemonRepository.getPokemonsPageCalls.first?.limit, 3)
        XCTAssertEqual(items, pokemons)
    }
}
