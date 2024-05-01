//
//  RemotePokemonDetails.swift
//
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation

/// Schema: https://github.com/PokeAPI/api-data/blob/master/data/schema/v2/pokemon/%24id/index.json
struct RemotePokemonDetails: Decodable, Equatable {
    var id: Int
    var name: String
    var weight: Int
    var height: Int
    var order: Int
    var types: [SlotType]
    var sprites: Sprites
    
    struct Sprites: Decodable, Equatable {
        var backDefault: URL?
        var backFemale: URL?
        var backShiny: URL?
        var backShiny_female: URL?
        var frontDefault: URL?
        var frontFemale: URL?
        var frontShiny: URL?
        var frontShinyFemale: URL?
        var other: Other?
        
        struct Other: Decodable, Equatable {
            var home: Home?
            
            struct Home: Decodable, Equatable {
                var frontDefault: URL?
                var frontFemale: URL?
                var frontShiny: URL?
                var frontShinyFemale: URL?
            }
        }
    }
    
    struct SlotType: Decodable, Equatable {
        var slot: Int
        var type: RemoteNamedAPIResource
    }
}
