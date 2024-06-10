//
//  URLSessionNetworking.swift
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation
import Combine

// MARK: - Request builder -

/// Builds URLRequest from given inputs.
public final class URLSessionRequestBuilder {
    public init() {}
    
    public func buildRequest(method: String, url: URL, query: [String : String]?, headers: [String: String]?, body: Data?) async throws -> URLRequest {
        try await buildRequest(method: method, baseURL: url, path: nil, query: query, headers: headers, body: body)
    }
    
    /// Builds request from given parameters.
    private func buildRequest(method: String, baseURL: URL?, path: String?, query: [String : String]?, headers: [String: String]?, body: Data?) async throws -> URLRequest {
        // URL
        guard let url = baseURL?.appending(unsanitizedPath: path).appending(query: query) else {
            throw URLSessionJSONRequestBuilderError.failedToConstructURL
        }
        var request = URLRequest(url: url)
        
        // Method
        request.httpMethod = method
        
        // Headers
        headers?.forEach({ request.setValue($0.value, forHTTPHeaderField: $0.key) })
        
        // Body
        request.httpBody = body
        return request
    }
}

// MARK: - Service -

/// Performs given request, decodes raw data and returns decoded object.
public final class URLSessionRequestService {
    private let session: URLSession
    
    public init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }
    
    public func performRequest<T: Decodable, D: TopLevelDecoder>(_ request: URLRequest, decodedTo: T.Type, decoder: D) async throws -> T where D.Input == Data {
        let response = try await session.data(for: request)
        return try decoder.decode(T.self, from: response.0)
    }
}

// MARK: - Support -

public enum URLSessionJSONRequestBuilderError: Error {
    case failedToConstructURL
}
