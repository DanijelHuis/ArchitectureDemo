//
//  DefaultPokemonRepositoryTests.swift
//
//
//  Created by Danijel Huis on 04.05.2024..
//

import XCTest
@testable import Data

final class DefaultPokemonRepositoryTests: XCTestCase {
    private var httpClient: MockHTTPClient!
    private var sut: DefaultPokemonListRepository!
    
    private struct Mock {
        static let pokemonsResponse = RemoteNamedAPIResourceList(count: 2, results: [.init(name: "pokemon1"), .init(name: "pokemon2")])
        static let pokemonDetailsResponse = RemotePokemonDetails.mock(id: 1, sprites: .mock(frontDefault: URL(string: "Pokemon1_frontDefault"),
                                                                                            homeFrontDefault: URL(string: "Pokemon1_home_frontDefault")))
    }
    
    override func setUp() {
        httpClient = .init()
        sut = .init(httpClient: httpClient)
    }
    
    override func tearDown() {
        httpClient = nil
        sut = nil
    }
    
    // MARK: - getPokemonsPage -

    func test_getPokemonsPage_thenSetsRequestCorrectly() async throws {
        // Given
        httpClient.setup(buildRequest: true, authorizeRequest: true, response: Mock.pokemonsResponse)
        // When
        _ = try await sut.getPokemonsPage(offset: 5, limit: 10)
        // Then
        XCTAssertEqual(httpClient.buildRequestCalls.count, 1)
        XCTAssertEqual(httpClient.buildRequestCalls.first?.path, "pokemon")
        XCTAssertEqual(httpClient.buildRequestCalls.first?.method, .get)
        XCTAssertEqual(httpClient.buildRequestCalls.first?.headers, nil)
        XCTAssertEqual(httpClient.buildRequestCalls.first?.body, nil)
        XCTAssertEqual(httpClient.buildRequestCalls.first?.query, ["offset": "5","limit": "10"])
    }
    
    func test_getPokemonsPage_givenResponse_thenMapsCorrectly() async throws {
        // Given
        httpClient.setup(buildRequest: true, authorizeRequest: true, response: Mock.pokemonsResponse)
        // When
        let page = try await sut.getPokemonsPage(offset: 5, limit: 10)
        // Then: maps remote to domain object correctly
        XCTAssertEqual(page.totalCount, 2)
        XCTAssertEqual(page.results.first, .init(id: "pokemon1", name: "Pokemon1"))
        XCTAssertEqual(page.results.last, .init(id: "pokemon2", name: "Pokemon2"))
    }
    
    func test_getPokemonsPage_runStandardTests() async throws {
        // Given
        httpClient.setup(buildRequest: true, authorizeRequest: true, response: Mock.pokemonsResponse)
        // Then
        await httpClient.runStandardTests(testCase: self, checkAuthorization: true) {
            // When
            _ = try await sut.getPokemonsPage(offset: 5, limit: 10)
        }
    }
}
