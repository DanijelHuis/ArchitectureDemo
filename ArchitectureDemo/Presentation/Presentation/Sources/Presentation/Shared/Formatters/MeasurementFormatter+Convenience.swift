//
//  MeasurementFormatter+Convenience.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation

extension MeasurementFormatter {
    convenience init(unitStyle: MeasurementFormatter.UnitStyle,
                     unitOptions: MeasurementFormatter.UnitOptions,
                     fractionDigits: Int,
                     locale: Locale) {
        self.init()
        self.unitStyle = unitStyle
        self.unitOptions = unitOptions
        self.numberFormatter.maximumFractionDigits = fractionDigits
        self.numberFormatter.minimumFractionDigits = fractionDigits
        self.locale = locale
    }
}
