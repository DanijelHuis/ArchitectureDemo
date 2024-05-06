//
//  MockWeightFormatter.swift
//
//
//  Created by Danijel Huis on 06.05.2024..
//

import Foundation
@testable import Presentation

final class MockWeightFormatter: WeightFormatter {
    var stringCalls = [Int]()
    var stringResult = UUID().uuidString
    
    func string(from weight: Int) -> String {
        stringCalls.append(weight)
        return stringResult
    }
}
