//
//  PokemonListViewSnapshotTests.swift
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

final class PokemonListSnapshotTests: XCTestCase {
    @MainActor func test_pokemonListView_givenError() throws {
        let reducer: MockReducerOf<PokemonListViewModel> = .init()
        let view = PokemonListView(store: .init(state: .error, reducer: reducer))
        assertSnapshot(of: host(view), as: .image(size: CGSize(width: 300, height: 600)))
    }
    
    @MainActor func test_pokemonListView_givenLoading() throws {
        let reducer: MockReducerOf<PokemonListViewModel> = .init()
        let view = PokemonListView(store: .init(state: .loading(), reducer: reducer))
        assertSnapshot(of: host(view), as: .image(size: CGSize(width: 300, height: 600)))
    }
    
    @MainActor func test_pokemonListView_givenLoaded() throws {
        let items = (0..<20).map({ PokemonListItemView.State(id: "pokemon \($0)", name: "Pokemon \($0)" ) })
        
        let reducer: MockReducerOf<PokemonListViewModel> = .init()
        let view = PokemonListView(store: .init(state: .loaded(items: items, hasMoreItems: false), reducer: reducer))
        assertSnapshot(of: host(view), as: .image(size: CGSize(width: 300, height: 600)))
    }
}
