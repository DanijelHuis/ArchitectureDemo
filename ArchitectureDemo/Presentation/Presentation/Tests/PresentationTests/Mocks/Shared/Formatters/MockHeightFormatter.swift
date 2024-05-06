//
//  MockHeightFormatter.swift
//
//
//  Created by Danijel Huis on 06.05.2024..
//

import Foundation
@testable import Presentation

final class MockHeightFormatter: HeightFormatter {
    var stringCalls = [Int]()
    var stringResult = UUID().uuidString
    
    func string(from height: Int) -> String {
        stringCalls.append(height)
        return stringResult
    }
}
