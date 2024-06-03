//
//  URL+PathTests.swift
//
//
//  Created by Danijel Huis on 04.05.2024..
//

import XCTest
@testable import URLSessionNetworking

class URLPathTests: XCTestCase {
    
    // MARK: - appending unsanitizedPath -
    
    private func appending(_ base: String, path: String?) -> String? {
        URL(string: base)?.appending(unsanitizedPath: path).absoluteString
    }
    
    func test_appendingUnsanitizedPath() {
        // When: base ends without slash, path all slash combinations
        XCTAssertEqual(appending("https://www.base.com/path1/path2", path: "/path3/path4"), "https://www.base.com/path1/path2/path3/path4")
        XCTAssertEqual(appending("https://www.base.com/path1/path2", path: "/path3/path4/"), "https://www.base.com/path1/path2/path3/path4/")
        XCTAssertEqual(appending("https://www.base.com/path1/path2", path: "path3/path4"), "https://www.base.com/path1/path2/path3/path4")
        XCTAssertEqual(appending("https://www.base.com/path1/path2", path: "path3/path4/"), "https://www.base.com/path1/path2/path3/path4/")
        
        // When: base ends with slash, path all slash combinations
        XCTAssertEqual(appending("https://www.base.com/path1/path2/", path: "/path3/path4"), "https://www.base.com/path1/path2/path3/path4")
        XCTAssertEqual(appending("https://www.base.com/path1/path2/", path: "/path3/path4/"), "https://www.base.com/path1/path2/path3/path4/")
        XCTAssertEqual(appending("https://www.base.com/path1/path2/", path: "path3/path4"), "https://www.base.com/path1/path2/path3/path4")
        XCTAssertEqual(appending("https://www.base.com/path1/path2/", path: "path3/path4/"), "https://www.base.com/path1/path2/path3/path4/")
        
        // When: base ends without slash, path is space, slash, empty or nil
        XCTAssertEqual(appending("https://www.base.com/path1/path2", path: " "), "https://www.base.com/path1/path2/%20")
        XCTAssertEqual(appending("https://www.base.com/path1/path2", path: "/"), "https://www.base.com/path1/path2/")
        XCTAssertEqual(appending("https://www.base.com/path1/path2", path: ""), "https://www.base.com/path1/path2")
        XCTAssertEqual(appending("https://www.base.com/path1/path2", path: nil), "https://www.base.com/path1/path2")
        
        // When: base ends with slash, path is space, slash, empty or nil
        XCTAssertEqual(appending("https://www.base.com/path1/path2/", path: " "), "https://www.base.com/path1/path2/%20")
        XCTAssertEqual(appending("https://www.base.com/path1/path2/", path: "/"), "https://www.base.com/path1/path2/")
        XCTAssertEqual(appending("https://www.base.com/path1/path2/", path: ""), "https://www.base.com/path1/path2/")
        XCTAssertEqual(appending("https://www.base.com/path1/path2/", path: nil), "https://www.base.com/path1/path2/")
        
        // When: path contains invalid characters
        XCTAssertEqual(appending("https://www.base.com/path1/path2/", path: "?&{}|\\^~[],`/path3"),
                       "https://www.base.com/path1/path2/%3F&%7B%7D%7C%5C%5E~%5B%5D,%60/path3")
    }
    
    // MARK: - appending query -
    
    private func appending(_ base: String, query: [String: String]?) -> String? {
        URL(string: base)?.appending(query: query)?.absoluteString
    }
    
    func test_appendingQuery() {
        // When: many unsorted query items
        XCTAssertEqual(appending("https://www.base.com/path1/path2", query: ["p5": "5", "p2": "2", "p4": "4", "p3": "3", "p1": "1"]),
                       "https://www.base.com/path1/path2?p1=1&p2=2&p3=3&p4=4&p5=5")
        
        // When: sinle query item
        XCTAssertEqual(appending("https://www.base.com/path1/path2", query: ["p1": "1"]), "https://www.base.com/path1/path2?p1=1")
        
        // When: query value is empty or space
        XCTAssertEqual(appending("https://www.base.com/path1/path2", query: ["p1": ""]), "https://www.base.com/path1/path2?p1=")
        XCTAssertEqual(appending("https://www.base.com/path1/path2", query: ["p1": " "]), "https://www.base.com/path1/path2?p1=%20")
        
        // When: query value has invalid characters
        XCTAssertEqual(appending("https://www.base.com/path1/path2", query: ["p1": "?&{}|\\^~[],`", "p2": "2"]),
                       "https://www.base.com/path1/path2?p1=?%26%7B%7D%7C%5C%5E~%5B%5D,%60&p2=2")
        
        // When: query name is empty or space
        XCTAssertEqual(appending("https://www.base.com/path1/path2", query: ["": "1"]), "https://www.base.com/path1/path2?=1")
        XCTAssertEqual(appending("https://www.base.com/path1/path2", query: [" ": "1"]), "https://www.base.com/path1/path2?%20=1")
        
        // When: query name has invalid characters
        XCTAssertEqual(appending("https://www.base.com/path1/path2", query: ["?&{}|\\^~[],`": "1", "p2": "2"]),
                       "https://www.base.com/path1/path2??%26%7B%7D%7C%5C%5E~%5B%5D,%60=1&p2=2")
        
        // When: query is nil or empty
        XCTAssertEqual(appending("https://www.base.com/path1/path2", query: nil), "https://www.base.com/path1/path2")
        XCTAssertEqual(appending("https://www.base.com/path1/path2", query: [:]), "https://www.base.com/path1/path2")
    }
}

