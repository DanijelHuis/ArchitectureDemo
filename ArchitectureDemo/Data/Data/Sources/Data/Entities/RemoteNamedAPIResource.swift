//
//  RemoteNamedAPIResource.swift
//
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation

/// Schema: https://github.com/PokeAPI/api-data/blob/master/data/schema/v2/named_api_resource.json
/// This is used for all APIs, e.g. pokemon and berry are API names.
struct RemoteNamedAPIResource: Codable, Hashable {
    public var name: String
    
    public enum CodingKeys: String, CodingKey {
        case name
    }
}

