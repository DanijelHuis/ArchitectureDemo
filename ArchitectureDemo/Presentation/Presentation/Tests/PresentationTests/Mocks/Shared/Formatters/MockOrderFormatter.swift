//
//  MockOrderFormatter.swift
//
//
//  Created by Danijel Huis on 06.05.2024..
//

import Foundation
@testable import Presentation

final class MockOrderFormatter: OrderFormatter {
    var stringCalls = [Int]()
    var stringResult = UUID().uuidString
    
    func string(from integer: Int) -> String {
        stringCalls.append(integer)
        return stringResult
    }
}
