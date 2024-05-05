//
//  PokemonListViewModelTests.swift
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
final class PokemonListViewModelTests: XCTestCase {
    private var getPokemonListUseCase: MockGetPokemonListUseCase!
    private var coordinator: MockCoordinator!
    private var sut: PokemonListViewModel!
    private var store: StoreOf<PokemonListViewModel>!
    private var state: PokemonListViewModel.State = .idle
    private var stateCalls = [PokemonListViewModel.State]()
    private var cancellables: Set<AnyCancellable> = []
    
    private struct Mock {
        static let pokemons = [Pokemon(id: "pokemon1", name: "Pokemon1"),
                               Pokemon(id: "pokemon2", name: "Pokemon2"),
                               Pokemon(id: "pokemon3", name: "Pokemon3")]
        
        static let listItems = pokemons.map({ PokemonListItemView.State(id: $0.id, name: $0.name) })
    }
    
    override func setUp() {
        getPokemonListUseCase = .init()
        coordinator = .init()
        sut = .init(getPokemonListUseCase: getPokemonListUseCase, coordinator: coordinator)
        store = .init(state: state, reducer: sut)
        
        store.$state.sink { [weak self] state in
            self?.stateCalls.append(state)
        }.store(in: &cancellables)
        stateCalls.removeAll()
    }
    
    override func tearDown() {
        getPokemonListUseCase = nil
        coordinator = nil
        sut = nil
        store = nil
    }
    
    // MARK: - loadNextPage -
    
    func test_loadNextPage_givenUseCaseSuccess_thenSetsStateToLoaded() async {
        // Given
        getPokemonListUseCase.getPokemonsNextPageResult = .success(Mock.pokemons)
        getPokemonListUseCase.hasNextPage = false
        // When
        await store.sendAndWait(.loadNextPage)
        print(NSLocalizedString("common_loading_wait", comment: ""))
        print("common_loading_wait".localized)

        // Then: sets loading and then loaded
        XCTAssertEqual(stateCalls, [.loading(text: "common_loading_wait".localizedOrRandom),
                                    .loaded(items: Mock.listItems, hasMoreItems: false)])
    }
    
    func test_loadNextPage_givenUseCaseFailure_thenSetsStateToError() async {
        // Given
        getPokemonListUseCase.getPokemonsNextPageResult = .failure(MockError.generalError("use case failure"))
        getPokemonListUseCase.hasNextPage = false
        // When
        await store.sendAndWait(.loadNextPage)
        // Then: sets loading and then error
        XCTAssertEqual(stateCalls, [.loading(text: "common_loading_wait".localized),
                                    .error])
    }
    
    func test_loadNextPage_givenPageAlreadyLoaded_thenDoesntSetStateToLoading() async {
        // Given
        getPokemonListUseCase.getPokemonsNextPageResult = .success(Mock.pokemons)
        getPokemonListUseCase.hasNextPage = false
        await store.sendAndWait(.loadNextPage)
        stateCalls.removeAll()
        // When: loadNextPage is called when we already have some items loaded
        await store.sendAndWait(.loadNextPage)
        // Then: first time reduce is called it will not set state to .loading, it will simply leave existing state and run effect after that.
        XCTAssertEqual(stateCalls, [.loaded(items: Mock.listItems, hasMoreItems: false),
                                    .loaded(items: Mock.listItems, hasMoreItems: false)])
    }
    
    // MARK: - hasMoreItems -
    
    func test_loadNextPage_givenHasNextPageIsTrue_thenHasMoreItemsIsSetToTrue() async {
        // Given
        getPokemonListUseCase.getPokemonsNextPageResult = .success(Mock.pokemons)
        getPokemonListUseCase.hasNextPage = true
        // When
        await store.sendAndWait(.loadNextPage)
        // Then
        XCTAssertEqual(store.state, .loaded(items: Mock.listItems, hasMoreItems: true))
    }
    
    func test_loadNextPage_givenHasNextPageIsFalse_thenHasMoreItemsIsSetToFalse() async {
        // Given
        getPokemonListUseCase.getPokemonsNextPageResult = .success(Mock.pokemons)
        getPokemonListUseCase.hasNextPage = false
        // When
        await store.sendAndWait(.loadNextPage)
        // Then
        XCTAssertEqual(store.state, .loaded(items: Mock.listItems, hasMoreItems: false))
    }
    
    // MARK: - openDetails -
    
    func test_openDetails_thenCallsCoordinator() {
        // When
        store.send(.openDetails(id: "10"))
        // Then
        XCTAssertEqual(coordinator.openRouteCalls, [.pokemons(.details(id: "10"))])
    }
}
