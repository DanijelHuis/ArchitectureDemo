//
//  TimeFormatter.swift
//
//
//  Created by Danijel Huis on 07.06.2024..
//

import Foundation

public struct TimeFormatter {
    private let locale: Locale
    private let timeZone: TimeZone
    private let format: Date.FormatStyle
    
    public init(locale: Locale, timeZone: TimeZone) {
        self.locale = locale
        self.timeZone = timeZone
        var format = Date.FormatStyle.dateTime
            .day().month(.wide).year()
            .hour().minute()
            .locale(locale)
        format.timeZone = timeZone
        self.format = format
    }
    
    public func string(from date: Date) -> String {
        date.formatted(format)
    }
}
