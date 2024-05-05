//
//  PokemonRepository.swift
//
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation

public protocol PokemonListRepository {
    func getPokemonsPage(offset: Int, limit: Int) async throws -> PokemonsPage
}
