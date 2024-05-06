//
//  PokemonDetailsViewModelTests.swift
//
//
//  Created by Danijel Huis on 05.05.2024..
//

import XCTest
import Domain
import Uniflow
import TestUtility
import Combine
@testable import Presentation

@MainActor
final class PokemonDetailsViewModelTests: XCTestCase {
    private var getPokemonDetailsUseCase: MockGetPokemonDetailsUseCase!
    private var stateMapper: MockLoadedStateMapper!
    private var sut: PokemonDetailsViewModel!
    private var store: StoreOf<PokemonDetailsViewModel>!
    private var state: PokemonDetailsViewModel.State = .idle
    private var stateCalls = [PokemonDetailsViewModel.State]()
    private var cancellables: Set<AnyCancellable> = []
    
    private struct Mock {
        static let pokemonDetails = PokemonDetails.mock()
        static let state = PokemonDetailsViewModel.LoadedState(name: "state name", imageURL: .init(string: "state_url"),
                                                               height: "state height", weight: "state weight",
                                                               order: "state order", type: "type")
    }
    
    override func setUp() {
        getPokemonDetailsUseCase = .init()
        stateMapper = .init()
        sut = .init(pokemonID: "10", getPokemonDetailsUseCase: getPokemonDetailsUseCase, stateMapper: stateMapper)
        store = .init(state: state, reducer: sut)
        
        store.$state.sink { [weak self] state in
            self?.stateCalls.append(state)
        }.store(in: &cancellables)
        stateCalls.removeAll()
    }
    
    override func tearDown() {
        getPokemonDetailsUseCase = nil
        stateMapper = nil
        sut = nil
        store = nil
    }
    
    // MARK: - getPokemonDetails -
    
    func test_getPokemonDetails_givenUseCaseSuccess_thenSetsStateToLoaded() async {
        // Given
        getPokemonDetailsUseCase.getPokemonDetailsResult = .success(Mock.pokemonDetails)
        stateMapper.mapResult = Mock.state
        // When
        await store.sendAndWait(.getPokemonDetails)
        
        // Then: sets loading and then loaded
        XCTAssertEqual(stateCalls, [.loading(text: "common_loading_wait".localizedOrRandom),
                                    .loaded(pokemonDetails: Mock.state)])
    }
    
    func test_getPokemonDetails_givenUseCaseFailure_thenSetsStateToError() async {
        // Given
        getPokemonDetailsUseCase.getPokemonDetailsResult = .failure(MockError.generalError("use case failure"))
        stateMapper.mapResult = Mock.state
        // When
        await store.sendAndWait(.getPokemonDetails)
        
        // Then: sets loading and then loaded
        XCTAssertEqual(stateCalls, [.loading(text: "common_loading_wait".localizedOrRandom),
                                    .error])
    }
}

private final class MockLoadedStateMapper: PokemonDetailsViewModel.LoadedStateMapper {
    var mapCalls = [PokemonDetails]()
    var mapResult = PokemonDetailsViewModel.LoadedState.init(name: UUID().uuidString,
                                                             height: UUID().uuidString,
                                                             weight: UUID().uuidString,
                                                             order: UUID().uuidString,
                                                             type: UUID().uuidString)
    func map(pokemonDetails: PokemonDetails) -> PokemonDetailsViewModel.LoadedState {
        mapCalls.append(pokemonDetails)
        return mapResult
    }
}

