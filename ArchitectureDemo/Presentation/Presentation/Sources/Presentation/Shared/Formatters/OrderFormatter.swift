//
//  OrderFormatter.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation

public protocol OrderFormatter {
    func string(from integer: Int) -> String
}

public struct PokemonOrderFormatter: OrderFormatter {
    private let locale: Locale
    
    public init(locale: Locale = .autoupdatingCurrent) {
        self.locale = locale
    }
    
    /// Adds # prefix and formats integer with minimum length of 3.
    public func string(from integer: Int) -> String {
        return "#" + integer
            .formatted(
                .number
                .precision(.integerLength(3...))
                .locale(locale))
    }
}
