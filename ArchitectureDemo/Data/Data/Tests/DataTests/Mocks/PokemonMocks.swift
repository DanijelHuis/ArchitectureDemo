//
//  PokemonMocks.swift
//
//
//  Created by Danijel Huis on 04.05.2024..
//

import Foundation
@testable import Data

extension RemotePokemonDetails {
    static func mock(id: Int,
                     name: String = "Pokemon1",
                     weight: Int = 100,
                     height: Int = 200,
                     order: Int = 300,
                     types: [SlotType] = [
                        .init(slot: 1, type: .init(name: "type1")),
                        .init(slot: 2, type: .init(name: "type2"))],
                     sprites: Sprites = .mock(spriteID: "Pokemon1")) -> RemotePokemonDetails {
        .init(id: id, name: name, weight: weight, height: height, order: order, types: types, sprites: sprites)
    }
}

extension RemotePokemonDetails.Sprites {
    static func mock(frontDefault: URL?, homeFrontDefault: URL?) -> RemotePokemonDetails.Sprites {
        .init(frontDefault: frontDefault,
              other: .init(home: .init(frontDefault: homeFrontDefault))
        )
    }
    
    static func mock(spriteID: String) -> RemotePokemonDetails.Sprites {
        .init(frontDefault: URL(string: "\(spriteID)_frontDefault"),
              other: .init(home: .init(frontDefault: URL(string: "\(spriteID)_home_frontDefault"))
                          )
        )
    }
}
