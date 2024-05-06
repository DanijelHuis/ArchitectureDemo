//
//  URLSessionNetworking.swift
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation

// MARK: - JSON request builder -

/// Builds URLRequest from given inputs. It adds JSON headers automatically.
public final class URLSessionJSONRequestBuilder {
    // @TODO can we make this non-optional?
    private let baseURL: URL?
    
    public init(baseURL: URL?) {
        self.baseURL = baseURL
    }
    
    public func buildRequest(method: String, path: String?, query: [String : String]?, headers: [String: String]?, body: Data?) async throws -> URLRequest {
        try await buildRequest(method: method, baseURL: baseURL, path: path, query: query, headers: headers, body: body)
    }
    
    /// Builds request from given parameters and also adds standard JSON headers.
    private func buildRequest(method: String, baseURL: URL?, path: String?, query: [String : String]?, headers: [String: String]?, body: Data?) async throws -> URLRequest {
        // URL
        guard let url = baseURL?.appending(unsanitizedPath: path).appending(query: query) else {
            throw URLSessionJSONRequestBuilderError.failedToConstructURL
        }
        var request = URLRequest(url: url)
        
        // Method
        request.httpMethod = method
        
        // Headers
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
    
    public func performRequest<T: Decodable>(_ request: URLRequest, decodedTo: T.Type, decoder: JSONDecoder) async throws -> T {
        let response = try await session.data(for: request)
        return try decoder.decode(T.self, from: response.0)
    }
}

// MARK: - Support -

public enum URLSessionJSONRequestBuilderError: Error {
    case failedToConstructURL
}
