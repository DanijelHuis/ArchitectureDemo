//
//  LoadedStateMapper.swift
//
//
//  Created by Danijel Huis on 06.05.2024..
//

import XCTest
import Domain
@testable import Presentation

final class PokemonDetailsViewModelLoadedStateMapperTests: XCTestCase {
    private var heightFormatter: MockHeightFormatter!
    private var weightFormatter: MockWeightFormatter!
    private var orderFormatter: MockOrderFormatter!
    private var sut: PokemonDetailsViewModel.LoadedStateMapper!
    
    override func setUp() {
        heightFormatter = .init()
        weightFormatter = .init()
        orderFormatter = .init()
        sut = PokemonDetailsViewModel.DefaultLoadedStateMapper(heightFormatter: heightFormatter,
                                                               weightFormatter: weightFormatter,
                                                               orderFormatter: orderFormatter)
    }
    
    override func tearDown() {
        heightFormatter = nil
        weightFormatter = nil
        orderFormatter = nil
        sut = nil
    }
    
    func test_map_thenMapsEverythingCorrectly() {
        // Given
        let pokemonDetails = PokemonDetails.mock()
        heightFormatter.stringResult = "test height"
        weightFormatter.stringResult = "test weight"
        orderFormatter.stringResult = "test order"
        // When
        let state = sut.map(pokemonDetails: pokemonDetails)
        // Then
        XCTAssertEqual(state.name, "Pokemon10")
        XCTAssertEqual(state.imageURL?.absoluteString, "sprite1")
        XCTAssertEqual(state.height, "test height")
        XCTAssertEqual(state.weight, "test weight")
        XCTAssertEqual(state.order, "test order")
        XCTAssertEqual(state.type, "pokemon_details_types".localizedOrRandom.replacingVariable("types", with: "type1, type2"))
    }
}
