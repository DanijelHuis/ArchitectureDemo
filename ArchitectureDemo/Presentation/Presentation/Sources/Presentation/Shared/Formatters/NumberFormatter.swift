//
//  NumberFormatter.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation

public protocol NumberFormatter {
    func string(from integer: Int) -> String
}

public struct PokemonOrderFormatter: NumberFormatter {
    public init() {}
    
    /// Adds # prefix and formats integer with minimum length of 3.
    public func string(from integer: Int) -> String {
        return "#" + integer.formatted(.number.precision(.integerLength(3...)))
    }
}
