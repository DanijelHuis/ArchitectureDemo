//
//  HTTPClient.swift
//  
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation

public protocol HTTPClient: RequestBuilder, RequestAuthorizer, RequestService {}

public protocol RequestBuilder {
    func buildRequest(method: HTTPMethod, path: String?, query: [String : String]?, headers: [String: String]?, body: Data?) async throws -> URLRequest
}

public protocol RequestAuthorizer {
    func authorizeRequest(_ request: URLRequest) async throws -> URLRequest
}

public protocol RequestService {
    func performRequest<T: Decodable>(_ request: URLRequest, decodedTo: T.Type) async throws -> T
}

public enum HTTPMethod: String {
    case get = "GET"
}

public enum StandardError: Error {
    case failedToCreateURL
    case noData
}

// MARK: - Convenience implementations -

public final class DefaultHTTPClient: HTTPClient {
    private let requestBuilder: RequestBuilder
    private let requestAuthorizer: RequestAuthorizer?
    private let requestService: RequestService
    
    public init(requestBuilder: RequestBuilder, requestAuthorizer: RequestAuthorizer?, requestService: RequestService) {
        self.requestBuilder = requestBuilder
        self.requestAuthorizer = requestAuthorizer
        self.requestService = requestService
    }
    
    public func buildRequest(method: HTTPMethod, path: String?, query: [String : String]?, headers: [String : String]?, body: Data?) async throws -> URLRequest {
        try await requestBuilder.buildRequest(method: method, path: path, query: query, headers: headers, body: body)
    }
    
    public func authorizeRequest(_ request: URLRequest) async throws -> URLRequest {
        if let requestAuthorizer {
            return try await requestAuthorizer.authorizeRequest(request)
        } else {
            return request
        }
    }
    
    public func performRequest<T>(_ request: URLRequest, decodedTo: T.Type) async throws -> T where T : Decodable {
        try await requestService.performRequest(request, decodedTo: decodedTo)
    }
}
