//
//  TimeFormatter.swift
//
//
//  Created by Danijel Huis on 07.06.2024..
//

import Foundation

struct TimeFormatter {
    private let locale: Locale
    private let timeZone: TimeZone
    private let format: Date.FormatStyle
    
    init(locale: Locale = Container.locale, timeZone: TimeZone = Container.timeZone) {
        self.locale = locale
        self.timeZone = timeZone
        var format = Date.FormatStyle.dateTime
            .day().month(.wide).year()
            .hour().minute()
            .locale(locale)
        format.timeZone = timeZone
        self.format = format
    }
    
    func string(from date: Date) -> String {
        date.formatted(format)
    }
}
