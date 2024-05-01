//
//  HeightFormatter.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation

public protocol HeightFormatterProtocol {
    func string(from height: Int) -> String
}

public struct PokemonHeightFormatter: HeightFormatterProtocol {
    private let formatter: MeasurementFormatter
    
    public init(locale: Locale = .autoupdatingCurrent) {
        formatter = MeasurementFormatter(unitStyle: .medium, unitOptions: .providedUnit, fractionDigits: 2, locale: locale)
    }
    
    /// Formats given integer with two fraction digits. Input is in decimeters and output is in centimeters.
    public func string(from height: Int) -> String {
        let height = Measurement(value: Double(height), unit: UnitLength.decimeters).converted(to: UnitLength.centimeters)
        return formatter.string(from: height)
    }
}
