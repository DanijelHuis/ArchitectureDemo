//
//  DefaultPokemonRepository.swift
//  
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation
import Domain

/// No datasources, everything is done in repository. If needed mapping can be injected.
final public class DefaultPokemonRepository: PokemonRepository {
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
    
    /// Fetches pokemon for given `name` (name serves as identifier).
    public func getPokemonDetails(id: String) async throws -> PokemonDetails {
        let path = "\(API.Endpoint.pokemon)/\(id)"
        var request = try await httpClient.buildRequest(method: .get,
                                                        path: path,
                                                        query: nil,
                                                        headers: nil,
                                                        body: nil)
        request = try await httpClient.authorizeRequest(request)
        let response = try await httpClient.performRequest(request, decodedTo: RemotePokemonDetails.self)
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

private extension RemotePokemonDetails {
    func mapped() -> PokemonDetails {
        let imageURL = [sprites.other?.home?.frontDefault, sprites.frontDefault, sprites.frontFemale, sprites.frontShiny, sprites.frontShinyFemale]
            .compactMap({ $0 })
            .first
        
        return PokemonDetails(
            id: id,
            name: name,
            weight: weight,
            height: height,
            order: order,
            types: types.map({ PokemonDetails.SlotType(slot: $0.slot, type: $0.type.name) }),
            imageURL: imageURL
        )
    }
}

