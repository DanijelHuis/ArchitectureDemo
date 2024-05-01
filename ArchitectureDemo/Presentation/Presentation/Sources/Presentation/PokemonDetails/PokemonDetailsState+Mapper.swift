//
//  PokemonDetailsState+Mapper.swift
//  
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation
import Domain

public protocol PokemonDetailsStateMapperProtocol {
    func map(pokemonDetails: PokemonDetails) -> PokemonDetailsViewModel.PokemonDetailsState
}

/// Maps PokemonDetails object to view state.
public struct PokemonDetailsStateMapper: PokemonDetailsStateMapperProtocol {
    private let heightFormatter: HeightFormatterProtocol
    private let weightFormatter: WeightFormatterProtocol
    private let orderFormatter: NumberFormatterProtocol
    
    public init(heightFormatter: HeightFormatterProtocol = PokemonHeightFormatter(),
                weightFormatter: WeightFormatterProtocol = PokemonWeightFormatter(),
                orderFormatter: NumberFormatterProtocol = PokemonOrderFormatter()) {
        self.heightFormatter = heightFormatter
        self.weightFormatter = weightFormatter
        self.orderFormatter = orderFormatter
    }
    
    public func map(pokemonDetails: PokemonDetails) -> PokemonDetailsViewModel.PokemonDetailsState {
        let typesString = pokemonDetails.types.map({ $0.type }).joined(separator: ", ")
        
        return .init(name: pokemonDetails.name.capitalized,
                     imageURL: pokemonDetails.imageURL,
                     height: heightFormatter.string(from: pokemonDetails.height),
                     weight: weightFormatter.string(from: pokemonDetails.weight),
                     order: orderFormatter.string(from: pokemonDetails.order),
                     type: "pokemon_details_types".localized.replacingVariable("types", with: typesString))
    }
}
