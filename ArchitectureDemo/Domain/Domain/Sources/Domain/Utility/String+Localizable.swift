//
//  String+Localizable.swift
//
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation

public extension String {
    /// Returns localized version of self (from asset catalogue).
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    /// Replaces variable in format {{variable}} with given value.
    /// We don't use native variable formatting (e.g. %1$@) because it can crash if wrong type is given. This is meant to be used with localizations which are
    /// especially error prone to mistakes (non-developers or extrnal companies writing translations).
    func replacingVariable(_ variable: String, with value: String) -> String {
        replacingOccurrences(of: "{{\(variable)}}", with: value)
    }
}
