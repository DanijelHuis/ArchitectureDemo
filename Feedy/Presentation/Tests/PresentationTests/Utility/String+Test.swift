//
//  String+Test.swift
//  
//
//  Created by Danijel Huis on 20.05.2024..
//

import Foundation

extension String {
    
    /// Returns localized string (self.localized) if it exists in the catalogue, otherwise returns random uuid.
    ///
    /// Why use this and not just .localized?
    ///   Because we want to check that localization is added to catalogue.
    ///   E.g. following test will succeed even if localization is not added to catalogue because both will return "title_key".
    ///   XCTAssertEqual(state.title, "title_key".localized)
    public var localizedOrRandom: String {
        let randomValue = UUID().uuidString
        let localizedValue = self.localized(default: randomValue)
        guard localizedValue != randomValue else { return randomValue }
        return localizedValue
    }
}
