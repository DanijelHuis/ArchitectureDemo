//
//  MockError.swift
//
//
//  Created by Danijel Huis on 04.05.2024..
//

import Foundation

public enum MockError: Error, Equatable {
    case mockNotSetup
    case generalError(_ description: String)
}
