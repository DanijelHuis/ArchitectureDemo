//
//  String+Localization.swift
//
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation

public extension String {
    /// Returns localized string (from asset catalogue). If localization is not found then it returns key.
    var localized: String {
        localized(default: "")
    }
    
    /// Returns localized string (from asset catalogue). If localization is not found then it returns default value.
    func localized(default value: String) -> String {
        NSLocalizedString(self, bundle: .module, value: value, comment: "")
    }
}
