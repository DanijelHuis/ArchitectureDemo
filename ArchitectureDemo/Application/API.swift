//
//  PokeAPIHTTPClient.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation
import Domain
import URLSessionNetworking

struct API {
    struct Poke {
        static let baseURL = URL(string: "https://pokeapi.co/api/v2/")
        static let client = DefaultHTTPClient(requestBuilder: URLSessionJSONRequestBuilder(baseURL: baseURL),
                                              requestAuthorizer: nil,
                                              requestService: URLSessionRequestService())
    }
}
