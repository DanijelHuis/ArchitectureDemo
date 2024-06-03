//
//  XCTest+Convenience.swift
//  
//
//  Created by Danijel Huis on 04.05.2024..
//

import Foundation
import XCTest

extension XCTest {    
    /// Similar to native XCTAssertThrowsError but async and takes equatable error as parameter instead of error closure.
    public func XCTAssertError<T, E: Error & Equatable>(
        _ expectedError: @escaping @autoclosure () -> E,
        message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line,
        _ expression: () async throws -> T) async {
            do {
                _ = try await expression()
                XCTFail("Expected to throw error. \(message())", file: file, line: line)
            } catch {
                guard let error = error as? E else {
                    XCTFail("Wrong Error type, expected \(String(describing: expectedError())) but got \(error)", file: file, line: line)
                    return
                }
                XCTAssertEqual(error, expectedError(), message(), file: file, line: line)
            }
        }
}

