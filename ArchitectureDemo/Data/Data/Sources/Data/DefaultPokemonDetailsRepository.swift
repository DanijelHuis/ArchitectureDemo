//
//  DefaultPokemonDetailsRepository.swift
//
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation
import Domain

final public class DefaultPokemonDetailsRepository: PokemonDetailsRepository {
    private let httpClient: HTTPClient
    
    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
        
    /// Fetches pokemon for given `id`.
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

private extension RemotePokemonDetails {
    func mapped() -> PokemonDetails {
        let imageURL = [sprites.other?.home?.frontDefault, sprites.frontDefault]
            .compactMap({ $0 })
            .first
        
        return PokemonDetails(
            id: id,
            name: name.capitalized,
            weight: weight,
            height: height,
            order: order,
            types: types.map({ $0.type.name }),
            imageURL: imageURL
        )
    }
}

