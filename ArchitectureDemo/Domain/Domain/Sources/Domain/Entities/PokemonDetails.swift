//
//  PokemonDetails.swift
//
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation

public struct PokemonDetails: Decodable, Equatable {
    public var id: Int
    public var name: String
    public var weight: Int
    public var height: Int
    public var order: Int
    public var types: [String]
    public var imageURL: URL?
    
    public init(id: Int, name: String, weight: Int, height: Int, order: Int, types: [String], imageURL: URL?) {
        self.id = id
        self.name = name
        self.weight = weight
        self.height = height
        self.order = order
        self.types = types
        self.imageURL = imageURL
    }
}
