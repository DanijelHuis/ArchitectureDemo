//
//  WeightFormatter.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation

public protocol WeightFormatterProtocol {
    func string(from weight: Int) -> String
}

public struct PokemonWeightFormatter: WeightFormatterProtocol {
    private let formatter: MeasurementFormatter
    
    public init(locale: Locale = .autoupdatingCurrent) {
        formatter = MeasurementFormatter(unitStyle: .medium, unitOptions: .providedUnit, fractionDigits: 2, locale: locale)
    }
    
    /// Formats integer with 2 fraction digits. Input is in hectograms and output is in kilograms.
    public func string(from weight: Int) -> String {
        let weight = Measurement(value: Double(weight), unit: UnitMass.hectograms).converted(to: UnitMass.kilograms)
        return formatter.string(from: weight)
    }
}

extension UnitMass {
    public static var hectograms = UnitMass(symbol: "hg", converter: UnitConverterLinear(coefficient: 0.1))
}
