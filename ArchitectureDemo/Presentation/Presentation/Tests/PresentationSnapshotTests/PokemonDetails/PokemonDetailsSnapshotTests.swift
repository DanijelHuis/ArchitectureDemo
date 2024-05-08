//
//  PokemonDetailsSnapshotTests.swift
//
//
//  Created by Danijel Huis on 07.05.2024..
//

import XCTest
import SnapshotTesting
import SwiftUI
import Domain
import Uniflow
@testable import Presentation

final class PokemonDetailsSnapshotTests: XCTestCase {
    @MainActor func test_pokemonDetailsView_givenError() throws {
        let reducer: MockReducerOf<PokemonDetailsViewModel> = .init()
        let view = PokemonDetailsView(store: .init(state: .error, reducer: reducer))
        assertSnapshot(of: host(view), as: .image(size: CGSize(width: 400, height: 500)))
    }
    
    @MainActor func test_pokemonDetailsView_givenLoading() throws {
        let reducer: MockReducerOf<PokemonDetailsViewModel> = .init()
        let view = PokemonDetailsView(store: .init(state: .loading(), reducer: reducer))
        assertSnapshot(of: host(view), as: .image(size: CGSize(width: 400, height: 500)))
    }
    
    @MainActor func test_pokemonDetailsView_givenLoaded() throws {
        let pokemonDetailsLoadedState = PokemonDetailsViewModel.LoadedState(
            name: "Pokemon1",
            height: "100.00 cm",
            weight: "50.00 kg",
            order: "#505",
            type: "Types: type, type"
        )
        
        let reducer: MockReducerOf<PokemonDetailsViewModel> = .init()
        let view = PokemonDetailsView(store: .init(state: .loaded(pokemonDetails: pokemonDetailsLoadedState), reducer: reducer))
        assertSnapshot(of: host(view), as: .image(size: CGSize(width: 400, height: 500)))
    }
    
    @MainActor func test_pokemonDetailsView_givenLoaded_givenLongText() throws {
        let pokemonDetailsLoadedState = PokemonDetailsViewModel.LoadedState(
            name: "Pokemon long long long long",
            height: "100.00 cm long long long long long long",
            weight: "50.00 kg long long long long long long",
            order: "#505 long long long long long long long long long long long long long long",
            type: "Types: type, type, type, type, type, type, type, type, type, type, type, type, type"
        )
        
        let reducer: MockReducerOf<PokemonDetailsViewModel> = .init()
        let view = PokemonDetailsView(store: .init(state: .loaded(pokemonDetails: pokemonDetailsLoadedState), reducer: reducer))
        assertSnapshot(of: host(view), as: .image(size: CGSize(width: 400, height: 600)))
    }
}