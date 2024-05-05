//
//  PokemonsPage.swift
//
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation

public struct PokemonsPage: Codable {
    public var totalCount: Int
    public var results: [Pokemon]
    
    public init(count: Int, results: [Pokemon]) {
        self.totalCount = count
        self.results = results
    }
}

