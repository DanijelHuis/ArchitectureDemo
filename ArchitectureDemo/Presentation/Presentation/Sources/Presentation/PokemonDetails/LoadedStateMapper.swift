//
//  PokemonDetailsLoadedStateMapper+Mapper.swift
//
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation
import Domain

extension PokemonDetailsViewModel {
    public protocol LoadedStateMapper {
        func map(pokemonDetails: PokemonDetails) -> PokemonDetailsViewModel.LoadedState
    }
    
    /// Maps PokemonDetails object to view state.
    public struct DefaultLoadedStateMapper: LoadedStateMapper {
        private let heightFormatter: HeightFormatter
        private let weightFormatter: WeightFormatter
        private let orderFormatter: OrderFormatter
        
        public init(heightFormatter: HeightFormatter = PokemonHeightFormatter(),
                    weightFormatter: WeightFormatter = PokemonWeightFormatter(),
                    orderFormatter: OrderFormatter = PokemonOrderFormatter()) {
            self.heightFormatter = heightFormatter
            self.weightFormatter = weightFormatter
            self.orderFormatter = orderFormatter
        }
        
        public func map(pokemonDetails: PokemonDetails) -> PokemonDetailsViewModel.LoadedState {
            let typesString = pokemonDetails.types.joined(separator: ", ")
            
            return .init(name: pokemonDetails.name,
                         imageURL: pokemonDetails.imageURL,
                         height: heightFormatter.string(from: pokemonDetails.height),
                         weight: weightFormatter.string(from: pokemonDetails.weight),
                         order: orderFormatter.string(from: pokemonDetails.order),
                         type: "pokemon_details_types".localized.replacingVariable("types", with: typesString))
        }
    }
}
