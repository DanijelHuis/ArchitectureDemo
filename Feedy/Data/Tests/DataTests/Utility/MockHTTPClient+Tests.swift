//
//  MockHTTPClient+Tests.swift
//  
//
//  Created by Danijel Huis on 04.05.2024..
//

import Foundation
import Domain
import XCTest
import TestUtility

extension MockHTTPClient {
    static let originalRequest = URLRequest(url: URL(string: "https://original")!)
    static let authorizedRequest = URLRequest(url: URL(string: "https://authorized")!)

    /// What does it test:
    /// - that buildRequest is called only once
    /// - that authorizeRequest is called once and with correct request (only tested if checkAuthorization is true)
    /// - that performRequest is called once and with correct request
    /// - when buildRequest fails it should throw correct error
    /// - when authorizeRequest fails it should throw correct error (only tested if checkAuthorization is true)
    /// - when performRequest fails it should throw correct error
    func runStandardTests<T>(testCase: XCTestCase, checkAuthorization: Bool = true, file: StaticString = #filePath, line: UInt = #line, closure: () async throws -> T) async {
        setup(buildRequest: true, authorizeRequest: true, response: nil)
        _ = try? await closure()
        // Check that buildRequest is called once
        XCTAssertEqual(buildRequestCalls.count, 1, file: file, line: line)
        if checkAuthorization {
            // Check that authorizeRequest is called once and with request from buildRequest
            XCTAssertEqual(authorizeRequestCalls.count, 1, file: file, line: line)
            XCTAssertEqual(authorizeRequestCalls.first, MockHTTPClient.originalRequest, file: file, line: line)
            // Check that performRequest is called once and with request from authorizeRequest
            XCTAssertEqual(performRequestCalls.count, 1, file: file, line: line)
            XCTAssertEqual(performRequestCalls.first?.request, MockHTTPClient.authorizedRequest, file: file, line: line)
        } else {
            // Check that performRequest is called once and with request from authorizeRequest
            XCTAssertEqual(performRequestCalls.count, 1, file: file, line: line)
            XCTAssertEqual(performRequestCalls.first?.request, MockHTTPClient.originalRequest, file: file, line: line)
        }
        
        // When buildRequest fails then throw error
        setup(buildRequest: false, authorizeRequest: false, response: nil)
        await testCase.XCTAssertError(MockError.generalError("build request failed"),
                                      message: "Expected to get error when buildRequest fails",
                                      file: file, line: line) {
            try await closure()
        }
        
        if checkAuthorization {
            // When authorize request fails then throw error
            setup(buildRequest: true, authorizeRequest: false, response: nil)
            
            await testCase.XCTAssertError(MockError.generalError("authorize request failed"),
                                          message: "Expected to get error when authorizeRequest fails", file: file, line: line) {
                try await closure()
            }
        }
        
        // When perform request fails then throw error
        setup(buildRequest: true, authorizeRequest: true, response: nil)
        await testCase.XCTAssertError(MockError.generalError("perform request failed"),
                                      message: "Expected to get error when performRequest fails",
                                      file: file, line: line) {
            try await closure()
        }
    }
}
