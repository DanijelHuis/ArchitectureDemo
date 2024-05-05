//
//  DefaultGetPokemonsUseCaseTests.swift
//
//
//  Created by Danijel Huis on 04.05.2024..
//

import XCTest
@testable import Domain

final class DefaultGetPokemonsUseCaseTests: XCTestCase {
    private var pokemonListRepository: MockPokemonListRepository!
    private var sut: DefaultGetPokemonsUseCase!
    private var pageSize = 3
    
    private struct Mock {
        static func pokemons(startIndex: Int, count: Int) -> [Pokemon] {
            Array((startIndex..<startIndex + count)).reduce(into: [Pokemon]()) { partialResult, index in
                partialResult.append(.init(id: "pokemon\(index)", name: "Pokemon\(index))"))
            }
        }
    }
    
    override func setUp() {
        pokemonListRepository = .init()
        sut = .init(pokemonListRepository: pokemonListRepository, pageSize: pageSize)
    }
    
    override func tearDown() {
        pokemonListRepository = nil
        sut = nil
    }
    
    // MARK: - getPokemonsNextPage -
    
    func test_getPokemonsNextPage_givenNotCalledBefore_thenRequestsFirstPage_thenReturnsCorrectItems() async throws {
        let pokemons = Mock.pokemons(startIndex: 0, count: pageSize)
        pokemonListRepository.getPokemonsPageResult = .success(.init(count: 8, results: pokemons))
        // When
        let items = try await sut.getPokemonsNextPage()
        // Then
        XCTAssertEqual(pokemonListRepository.getPokemonsPageCalls.count, 1)
        XCTAssertEqual(pokemonListRepository.getPokemonsPageCalls.first?.offset, 0)
        XCTAssertEqual(pokemonListRepository.getPokemonsPageCalls.first?.limit, 3)
        XCTAssertEqual(items, pokemons)
    }
    
    func test_getPokemonsNextPage_givenCalledMultipleTimes_thenAppendsItemsForEachPage() async throws {
        let pokemons1 = Mock.pokemons(startIndex: 0, count: pageSize)
        let pokemons2 = Mock.pokemons(startIndex: 3, count: pageSize)
        let pokemons3 = Mock.pokemons(startIndex: 6, count: pageSize)
        // When
        pokemonListRepository.getPokemonsPageResult = .success(.init(count: 10, results: pokemons1))
        let items1 = try await sut.getPokemonsNextPage()
        pokemonListRepository.getPokemonsPageResult = .success(.init(count: 10, results: pokemons2))
        let items2 = try await sut.getPokemonsNextPage()
        pokemonListRepository.getPokemonsPageResult = .success(.init(count: 10, results: pokemons3))
        let items3 = try await sut.getPokemonsNextPage()
        
        XCTAssertEqual(pokemonListRepository.getPokemonsPageCalls.count, 3)
        
        // Then: first call request correct offset/limit and returns items for first page.
        XCTAssertEqual(pokemonListRepository.getPokemonsPageCalls[0].offset, 0)
        XCTAssertEqual(pokemonListRepository.getPokemonsPageCalls[0].limit, 3)
        XCTAssertEqual(items1, pokemons1)
        
        // Then: second call request correct offset/limit and returns items for first and second page
        XCTAssertEqual(pokemonListRepository.getPokemonsPageCalls[1].offset, 3)
        XCTAssertEqual(pokemonListRepository.getPokemonsPageCalls[1].limit, 3)
        XCTAssertEqual(items2, pokemons1 + pokemons2)
        
        // Then: third call request correct offset/limit and returns correct for all pages.
        XCTAssertEqual(pokemonListRepository.getPokemonsPageCalls[2].offset, 6)
        XCTAssertEqual(pokemonListRepository.getPokemonsPageCalls[2].limit, 3)
        XCTAssertEqual(items3, pokemons1 + pokemons2 + pokemons3)
    }
    
    // MARK: - hasNextPage -
        
    func test_hasNextPage_givenCalledBeforeGetNextPageCalled_thenReturnsFalse() async throws {
        // Then
        XCTAssertEqual(sut.hasNextPage, false)
    }
    
    func test_hasNextPage_givenItemCountIsLessThanTotal_thenReturnsTrue() async throws {
        // Given
        let pokemons = Mock.pokemons(startIndex: 0, count: pageSize)
        pokemonListRepository.getPokemonsPageResult = .success(.init(count: 8, results: pokemons))
        // When
        _ = try await sut.getPokemonsNextPage()
        // Then: we got 3 items but there are 8 total
        XCTAssertEqual(sut.hasNextPage, true)
    }
    
    func test_hasNextPage_givenItemCountIsEqualToTotal_thenReturnsFalse() async throws {
        // Given
        let pokemons = Mock.pokemons(startIndex: 0, count: pageSize)
        pokemonListRepository.getPokemonsPageResult = .success(.init(count: 3, results: pokemons))
        // When
        _ = try await sut.getPokemonsNextPage()
        // Then: we got 3 items out of 3 total
        XCTAssertEqual(sut.hasNextPage, false)
    }

    func test_hasNextPage_givenGetNextPageCalledUnitlEnd_thenHasNextPageReturnsCorrectValues() async throws {
        let pokemons1 = Mock.pokemons(startIndex: 0, count: pageSize)
        let pokemons2 = Mock.pokemons(startIndex: 3, count: pageSize)
        let pokemons3 = Mock.pokemons(startIndex: 6, count: 2)

        // Then: returns false before first getPokemonsNextPage because it doesn't know how many there are on backend.
        XCTAssertEqual(sut.hasNextPage, false)
        
        // When: first getPokemonsNextPage call
        pokemonListRepository.getPokemonsPageResult = .success(.init(count: 8, results: pokemons1))
        _ = try await sut.getPokemonsNextPage()
        // Then: 3 out of 8 fetched - hasNextPage should be true
        XCTAssertEqual(sut.hasNextPage, true)
        
        // When: second getPokemonsNextPage call
        pokemonListRepository.getPokemonsPageResult = .success(.init(count: 8, results: pokemons2))
        _ = try await sut.getPokemonsNextPage()
        // Then: 6 out of 8 fetched - hasNextPage should be true
        XCTAssertEqual(sut.hasNextPage, true)
        
        // When: third getPokemonsNextPage call
        pokemonListRepository.getPokemonsPageResult = .success(.init(count: 8, results: pokemons3))
        _ = try await sut.getPokemonsNextPage()
        // Then: 8 out of 8 fetched - hasNextPage should be false
        XCTAssertEqual(sut.hasNextPage, false)
    }
    
    // MARK: - removeAllPages -
    
    func test_removeAllPages_thenResetsPagesAndItems() async throws {
        let pokemons = Mock.pokemons(startIndex: 0, count: pageSize)
        pokemonListRepository.getPokemonsPageResult = .success(.init(count: 8, results: pokemons))
        _ = try await sut.getPokemonsNextPage()
        // When
        sut.removeAllPages()
        let items = try await sut.getPokemonsNextPage()
        
        XCTAssertEqual(pokemonListRepository.getPokemonsPageCalls.count, 2)

        // Then: first call requets offset 0 because it is first call
        XCTAssertEqual(pokemonListRepository.getPokemonsPageCalls[0].offset, 0)
        XCTAssertEqual(pokemonListRepository.getPokemonsPageCalls[0].limit, 3)
        XCTAssertEqual(items, pokemons)
        
        // Then: second call requets offset 0 again because we called removeAllPages, also it returns only items for last fetch which means it cleared items correctly.
        XCTAssertEqual(pokemonListRepository.getPokemonsPageCalls[1].offset, 0)
        XCTAssertEqual(pokemonListRepository.getPokemonsPageCalls[1].limit, 3)
        XCTAssertEqual(items, pokemons)
    }
}
