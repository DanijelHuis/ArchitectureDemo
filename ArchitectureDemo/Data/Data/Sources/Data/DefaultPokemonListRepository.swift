//
//  DefaultPokemonRepository.swift
//  
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation
import Domain

final public class DefaultPokemonListRepository: PokemonListRepository {
    private let httpClient: HTTPClient
    
    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    /// Fetches pokemons for given `offset` and `limit`.
    public func getPokemonsPage(offset: Int, limit: Int) async throws -> PokemonsPage {
        let query = ["offset": String(offset),
                     "limit": String(limit)]
        
        var request = try await httpClient.buildRequest(method: .get,
                                                        path: API.Endpoint.pokemon,
                                                        query: query,
                                                        headers: nil,
                                                        body: nil)
        request = try await httpClient.authorizeRequest(request)
        let response = try await httpClient.performRequest(request, decodedTo: RemoteNamedAPIResourceList.self)
        return response.mapped()
    }
}

// MARK: - Remote to Domain mapping (put this elsewhere and inject if needed) -

extension RemoteNamedAPIResourceList {
    func mapped() -> PokemonsPage {
        PokemonsPage(count: count, results: results.map({ $0.mapped() }))
    }
}

private extension RemoteNamedAPIResource {
    func mapped() -> Pokemon {
        Pokemon(id: name, name: name.capitalized)
    }
}
