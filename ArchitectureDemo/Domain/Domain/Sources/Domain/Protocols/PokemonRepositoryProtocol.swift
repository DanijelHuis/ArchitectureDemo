//
//  PokemonRepositoryProtocol.swift
//
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation

public protocol PokemonRepositoryProtocol {
    func getPokemonsPage(offset: Int, limit: Int) async throws -> PokemonsPage
    func getPokemonDetails(id: String) async throws -> PokemonDetails
}
