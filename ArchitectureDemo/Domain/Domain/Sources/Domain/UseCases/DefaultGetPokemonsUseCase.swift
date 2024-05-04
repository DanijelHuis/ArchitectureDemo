//
//  GetPokemonsUseCase.swift
//  
//
//  Created by Danijel Huis on 01.05.2024..
//
import Foundation

public protocol GetPokemonsUseCase {
    func getPokemonsNextPage() async throws -> [Pokemon]
    func removeAllPages()
    var hasNextPage: Bool { get }
}

/// Fetches pokemons. It keeps track of current page and stores items for previously fetched pages.
public final class DefaultGetPokemonsUseCase: GetPokemonsUseCase {
    private let pokemonRepository: PokemonRepository
    private let paginationManager: PaginationManager
    private var items = [Pokemon]()
    
    public init(pokemonRepository: PokemonRepository, pageSize: Int) {
        self.pokemonRepository = pokemonRepository
        // No reason to inject this because it has no side effects. We can inject if we want to explicitly mock.
        self.paginationManager = PaginationManager(pageSize: pageSize)
    }
    
    /// Fetches next page, if no next page (not fetched before or end of the line) then it will fetch first page.
    /// Returned array contains pokemons for all pages and not just for the page that is being fetched.
    public func getPokemonsNextPage() async throws -> [Pokemon] {
        let nextPage = paginationManager.nextPage ?? paginationManager.firstPage
        return try await getPage(nextPage)
    }
    
    private func getPage(_ page: Page) async throws -> [Pokemon] {
        let response = try await pokemonRepository.getPokemonsPage(offset: page.offset, limit: page.limit)
        paginationManager.addPage(page, totalItemCount: response.count)
        items.append(contentsOf: response.results)
        return items
    }
    
    /// Returns true if there is next page. This will return true if pages were fetched previously and there is more items to fetch.
    public var hasNextPage: Bool { paginationManager.nextPage != nil }
    
    /// Resets all data - page index and accumulated items.
    public func removeAllPages() {
        paginationManager.removeAllPages()
        items.removeAll()
    }
}

enum DefaultPokemonListRepositoryError: Error {
    case noNextPage
}
