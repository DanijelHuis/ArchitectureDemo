//
//  PokemonMocks.swift
//
//
//  Created by Danijel Huis on 06.05.2024..
//

import Foundation
@testable import Domain

extension PokemonDetails {
    static func mock(id: Int = 10,
                     name: String = "Pokemon10",
                     weight: Int = 100,
                     height: Int = 200,
                     order: Int = 300,
                     types: [String] = ["type1", "type2"],
                     imageURL: URL? = .init(string: "sprite1")) -> PokemonDetails {
        .init(id: id, name: name, weight: weight, height: height, order: order, types: types, imageURL: imageURL)
    }
}
