//
//  PokemonAvatarView.swift
//  
//
//  Created by Danijel Huis on 01.05.2024..
//

import SwiftUI

/// Used to show pokemon icon on coloured circle background.
struct PokemonAvatarView: View {
    private let imageURL: URL?
    
    init(imageURL: URL?) {
        self.imageURL = imageURL
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(.background1).opacity(0.5))
                .padding(.horizontal, 40)
            
            AsyncImage(url: imageURL) { image in
                image.image?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
}
