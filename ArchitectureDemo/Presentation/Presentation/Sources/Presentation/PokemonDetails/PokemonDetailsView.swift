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
    /// Since view model can be any Store with same State/Action, that means that we can easily inject mock store for preview or snapshot testing. That also means that we can start
    /// making UI before any other logic is done.
    @ObservedObject private var viewModel: StoreOf<PokemonDetailsViewModel>
    /// Details view will have random background color that is not related to data.
    @State private var background = [ColorResource.background3, .background4, .background3].randomElement() ?? .background3
    
    public init(viewModel: StoreOf<PokemonDetailsViewModel>) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            Color(self.background).edgesIgnoringSafeArea(.all)
            
            switch viewModel.state {
            // Idle
            case .idle:
                EmptyView()
                
            // Loading
            case .loading(let text):
                LoadingView(text: text)
                
            // Error
            case .error:
                TryAgainView {
                    viewModel.send(.getPokemonDetails)
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
                        .textStyle(.heading1)
                    
                    // Type
                    Text(state.type)
                        .textStyle(.body1)
                }
                .padding(.spacing.double)
            }
        }
        .onFirstAppear {
            viewModel.send(.getPokemonDetails)
        }
    }
}
