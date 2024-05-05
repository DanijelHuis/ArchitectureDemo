//
//  PokemonDetailsRepository.swift
//  
//
//  Created by Danijel Huis on 05.05.2024..
//

import Foundation

public protocol PokemonDetailsRepository {
    func getPokemonDetails(id: String) async throws -> PokemonDetails
}
