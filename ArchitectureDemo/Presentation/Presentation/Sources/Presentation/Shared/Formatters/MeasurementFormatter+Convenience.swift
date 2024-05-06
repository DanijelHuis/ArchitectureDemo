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
        // It seems we have to set locale first, e.g. if we set locale after fraction digits then fraction digits are not applied.
        // see StackOverflow 55180097
        self.locale = locale
        self.unitStyle = unitStyle
        self.unitOptions = unitOptions
        self.numberFormatter.maximumFractionDigits = fractionDigits
        self.numberFormatter.minimumFractionDigits = fractionDigits
    }
}
