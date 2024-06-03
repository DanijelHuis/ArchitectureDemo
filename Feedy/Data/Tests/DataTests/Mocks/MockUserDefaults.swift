//
//  MockUserDefaults.swift
//
//
//  Created by Danijel Huis on 19.05.2024..
//

import Foundation

class MockUserDefaults : UserDefaults {
    convenience init() {
        self.init(suiteName: "Mock User Defaults")!
    }
    
    override init?(suiteName suitename: String?) {
        UserDefaults().removePersistentDomain(forName: suitename!)
        super.init(suiteName: suitename)
    }
}
