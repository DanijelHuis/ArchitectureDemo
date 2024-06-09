//
//  Container.swift
//
//
//  Created by Danijel Huis on 07.06.2024..
//

import Foundation

/// Poor man's dependency injection.
struct Container {
    static var locale: Locale = .autoupdatingCurrent
    static var timeZone: TimeZone = .autoupdatingCurrent
}
