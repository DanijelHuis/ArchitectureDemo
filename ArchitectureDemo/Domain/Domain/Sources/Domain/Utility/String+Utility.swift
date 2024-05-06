//
//  String+Utility.swift
//
//
//  Created by Danijel Huis on 06.05.2024..
//

import Foundation

extension String {
    /// Replaces variable in format {{variable}} with given value.
    /// We don't use native variable formatting (e.g. %1$@) because it can crash if wrong type is given. This is meant to be used with localizations which are
    /// especially error prone to mistakes (non-developers or extrnal companies writing translations).
    public func replacingVariable(_ variable: String, with value: String) -> String {
        replacingOccurrences(of: "{{\(variable)}}", with: value, options: [.caseInsensitive])
    }
}
