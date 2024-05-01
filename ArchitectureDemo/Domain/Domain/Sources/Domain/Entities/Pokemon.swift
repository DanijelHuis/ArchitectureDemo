//
//  Pokemon.swift
//
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation

public struct Pokemon: Codable {
    public var id: String
    public var name: String
    
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
