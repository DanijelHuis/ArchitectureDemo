//
//  File.swift
//  
//
//  Created by Danijel Huis on 05.05.2024..
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
        print(NSLocalizedString(self, comment: ""))
        let randomValue = UUID().uuidString
        let localizedValue = NSLocalizedString(self, tableName: nil, value: randomValue, comment: "")
        guard localizedValue != randomValue else { return randomValue }
        return localizedValue
    }
}
