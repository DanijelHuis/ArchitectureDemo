//
//  PokemonDetailsView.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import SwiftUI
import Domain
import Uniflow

public struct PokemonDetailsView: View {
    /// Since store can be any Store with same State/Action, that means that we can easily inject mock store for preview or snapshot testing. That also means that we can start
    /// making UI before any other logic is done.
    @ObservedObject private var store: StoreOf<PokemonDetailsViewModel>
    
    public init(store: StoreOf<PokemonDetailsViewModel>, background: Color? = nil) {
        self.store = store
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            Color(ColorResource.background3).edgesIgnoringSafeArea(.all)
            
            switch store.state {
            // Idle
            case .idle:
                EmptyView()
                
            // Loading
            case .loading(let text):
                LoadingView(text: text)
                
            // Error
            case .error:
                TryAgainView {
                    store.send(.getPokemonDetails)
                }
                
            // Loaded
            case .loaded(let state):
                VStack(spacing: .spacing.double) {
                    // Avatar
                    PokemonAvatarView(imageURL: state.imageURL)
                        .frame(height: 240)
                    
                    // Height and weight
                    HStack(spacing: .spacing.normal) {
                        Image(systemName: "ruler.fill")
                        Text(state.height)
                            .textStyle(.body1)
                        
                        Spacer()
                        
                        Image(systemName: "scalemass.fill")
                        Text(state.weight)
                            .textStyle(.body1)
                    }
                    .padding(.horizontal, .spacing.quad)
                    
                    // Order
                    CapsuleText(text: state.order)
                    
                    // Name
                    Text(state.name)
                        .multilineTextAlignment(.center)
                        .textStyle(.heading1)
                    
                    // Type
                    Text(state.type)
                        .multilineTextAlignment(.center)
                        .textStyle(.body1)
                }
                .padding(.spacing.double)
            }
        }
        .onFirstAppear {
            store.send(.getPokemonDetails)
        }
    }
}
