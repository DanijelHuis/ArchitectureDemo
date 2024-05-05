//
//  DefaultPokemonDetailsRepositoryTests.swift
//
//
//  Created by Danijel Huis on 04.05.2024..
//

import XCTest
@testable import Data

final class DefaultPokemonDetailsRepositoryTests: XCTestCase {
    private var httpClient: MockHTTPClient!
    private var sut: DefaultPokemonDetailsRepository!
    
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
    
    func test_getPokemonDetails_thenSetsRequestCorrectly() async throws {
        // Given
        httpClient.setup(buildRequest: true, authorizeRequest: true, response: Mock.pokemonDetailsResponse)
        // When
        _ = try await sut.getPokemonDetails(id: "505")
        // Then
        XCTAssertEqual(httpClient.buildRequestCalls.count, 1)
        XCTAssertEqual(httpClient.buildRequestCalls.first?.path, "pokemon/505")
        XCTAssertEqual(httpClient.buildRequestCalls.first?.method, .get)
        XCTAssertEqual(httpClient.buildRequestCalls.first?.headers, nil)
        XCTAssertEqual(httpClient.buildRequestCalls.first?.body, nil)
        XCTAssertEqual(httpClient.buildRequestCalls.first?.query, nil)
    }
    
    func test_getPokemonDetails_thenMapsCorrectly() async throws {
        // Given
        let response = RemotePokemonDetails.mock(id: 1, sprites: .mock(frontDefault: URL(string: "Pokemon1_frontDefault"),
                                                                       homeFrontDefault: URL(string: "Pokemon1_home_frontDefault")))
        httpClient.setup(buildRequest: true, authorizeRequest: true, response: response)
        
        // When
        let pokemonDetails = try await sut.getPokemonDetails(id: "505")
        
        // Then: maps remote to domain object correctly
        XCTAssertEqual(pokemonDetails.id, 1)
        XCTAssertEqual(pokemonDetails.name, "Pokemon1")
        XCTAssertEqual(pokemonDetails.weight, 100)
        XCTAssertEqual(pokemonDetails.height, 200)
        XCTAssertEqual(pokemonDetails.order, 300)
        XCTAssertEqual(pokemonDetails.types, ["type1", "type2"])
        XCTAssertEqual(pokemonDetails.imageURL?.absoluteString, "Pokemon1_home_frontDefault")
    }
    
    func test_getPokemonDetails_givenNilHomeSprite_thenMapsFrontDefault() async throws {
        // Given
        let response = RemotePokemonDetails.mock(id: 1, sprites: .mock(frontDefault: URL(string: "Pokemon1_frontDefault"),
                                                                       homeFrontDefault: nil))
        httpClient.setup(buildRequest: true, authorizeRequest: true, response: response)
        
        // When
        let pokemonDetails = try await sut.getPokemonDetails(id: "505")
        
        // Then: returns frontDefault because homeFrontDefault is nil
        XCTAssertEqual(pokemonDetails.imageURL?.absoluteString, "Pokemon1_frontDefault")
    }
    
    func test_getPokemonDetails_givenNoSprites_thenMapsNil() async throws {
        // Given
        let response = RemotePokemonDetails.mock(id: 1, sprites: .mock(frontDefault: nil,
                                                                       homeFrontDefault: nil))
        httpClient.setup(buildRequest: true, authorizeRequest: true, response: response)
        
        // When
        let pokemonDetails = try await sut.getPokemonDetails(id: "505")
        
        // Then: returns nil because both urls are nil
        XCTAssertEqual(pokemonDetails.imageURL, nil)
    }
    
    func test_getPokemonDetails_runStandardTests() async throws {
        // Given
        httpClient.setup(buildRequest: true, authorizeRequest: true, response: Mock.pokemonDetailsResponse)
        // Then
        await httpClient.runStandardTests(testCase: self, checkAuthorization: true) {
            // When
            _ = try await sut.getPokemonDetails(id: "505")
        }
    }
}
