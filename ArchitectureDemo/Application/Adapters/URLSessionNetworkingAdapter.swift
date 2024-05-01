//
//  URLSessionNetworkingAdapter.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation
import Domain
import URLSessionNetworking

extension URLSessionJSONRequestBuilder: RequestBuilder {
    public func buildRequest(method: HTTPMethod, path: String?, query: [String : String]?, headers: [String : String]?, body: Data?) async throws -> URLRequest {
        try await buildRequest(method: method.rawValue, path: path, query: query, headers: headers, body: body)
    }
}

extension URLSessionRequestService: RequestService {
    public func performRequest<T>(_ request: URLRequest, decodedTo: T.Type) async throws -> T where T : Decodable {
        try await performRequest(request, decodedTo: decodedTo, decoder: decoder)
    }
    
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
