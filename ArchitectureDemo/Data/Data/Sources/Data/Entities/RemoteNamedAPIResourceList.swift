//
//  RemoteNamedAPIResourceList.swift
//
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation

/// Schema: https://github.com/PokeAPI/api-data/blob/master/data/schema/v2/named_api_resource_list.json
/// This is used for all APIs, e.g. pokemon and berry are API names.
struct RemoteNamedAPIResourceList: Codable {
    var count: Int
    var next: URL?
    var previous: URL?
    var results: [RemoteNamedAPIResource]
}
