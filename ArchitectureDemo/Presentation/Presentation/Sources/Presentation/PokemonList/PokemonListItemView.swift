//
//  PokemonListItemView.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import SwiftUI

public struct PokemonListItemView: View {
    /// No binding because it is part of list state which is ObservableObject. If any property of list item changes (inside PokemonListViewModel) then list state will change and rows will be updated.
    /// If something more complex is needed (e.g. we need to edit state from this view) then it should have its own view model or pass closure/publisher back to PokemonListViewModel.
    private let state: State
    
    init(state: State) {
        self.state = state
    }
    
    public var body: some View {
        HStack(spacing: .spacing.double) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(.foreground1).opacity(0.75))
                
                Image(.pokeballPlain)
                    .resizable()
                    .foregroundColor(Color(.foreground3))
                    .padding(5)
            }
            .frame(width: 30, height: 30)
            
            // Text
            Text(state.name)
                .textStyle(.listTitle)
            
            Spacer()
            
            // Disclosure indicator
            Image(systemName: "chevron.right")
                .foregroundColor(Color(.foreground2))
        }
        // Setting minHeight to allow cells to grow with dynamic font.
        .frame(minHeight: 44)
    }
}

// MARK: - State -

extension PokemonListItemView {
    public struct State: Equatable {
        var id: String
        var name: String
    }
}
