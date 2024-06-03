//
//  MockHTTPClient.swift
//
//
//  Created by Danijel Huis on 04.05.2024..
//

import Foundation
import Domain
import XCTest
import TestUtility

final class MockHTTPClient: HTTPClient {
    var buildRequestCalls = [(method: HTTPMethod, url: URL, query: [String : String]?, headers: [String : String]?, body: Data?)]()
    var buildRequestResult: Result<URLRequest, Error> = .failure(MockError.mockNotSetup)
    var authorizeRequestCalls = [URLRequest]()
    var authorizeRequestResult: Result<URLRequest, Error> = .failure(MockError.mockNotSetup)
    var performRequestCalls = [(request: URLRequest, type: Any)]()
    var performRequestResult: Result<Any, Error>?
    
    func buildRequest(method: HTTPMethod, url: URL, query: [String : String]?, headers: [String : String]?, body: Data?) async throws -> URLRequest {
        buildRequestCalls.append((method, url, query, headers, body))
        return try buildRequestResult.get()
    }
        
    func authorizeRequest(_ urlRequest: URLRequest) async throws -> URLRequest {
        authorizeRequestCalls.append(urlRequest)
        return try authorizeRequestResult.get()
    }
    
    func performRequest<T>(_ request: URLRequest, decodedTo type: T.Type) async throws -> T where T: Decodable {
        performRequestCalls.append((request, type))
        
        if let object = performRequestResult?.success as? T {
            return object
        } else {
            throw performRequestResult?.failure ?? MockError.generalError("Cannot cast performRequestResult type to \(T.self)")
        }
    }
}

extension MockHTTPClient {
    func setup(buildRequest: Bool, authorizeRequest: Bool, response: Any?) {
        buildRequestResult = buildRequest ? .success(MockHTTPClient.originalRequest) : .failure(MockError.generalError("build request failed"))
        authorizeRequestResult = authorizeRequest ? .success(MockHTTPClient.authorizedRequest) : .failure(MockError.generalError("authorize request failed"))
        
        if let response {
            performRequestResult = .success(response)
        } else {
            performRequestResult = .failure(MockError.generalError("perform request failed"))
        }
        
        buildRequestCalls.removeAll()
        authorizeRequestCalls.removeAll()
        performRequestCalls.removeAll()
    }
}
