//
//  URLSessionNetworkingAdapter.swift
//  Feedy
//
//  Created by Danijel Huis on 18.05.2024..
//

import Foundation
import Combine
import XMLCoder
import URLSessionNetworking
import Domain

extension URLSessionRequestBuilder: RequestBuilder {
    public func buildRequest(method: HTTPMethod, url: URL, query: [String : String]?, headers: [String : String]?, body: Data?) async throws -> URLRequest {
        try await buildRequest(method: method.rawValue, url: url, query: query, headers: headers, body: body)
    }
}

extension URLSessionRequestService: RequestService {
    public func performRequest<T>(_ request: URLRequest, decodedTo: T.Type) async throws -> T where T : Decodable {
        try await performRequest(request, decodedTo: decodedTo, decoder: decoder)
    }
    
    private var decoder: XMLDecoder {
        XMLDecoder()
    }
}

