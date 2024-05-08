//
//  PokemonListView.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import SwiftUI
import Domain
import Uniflow

public struct PokemonListView: View {
    /// Since store can be any Store with same State/Action, that means that we can easily inject mock store for preview or snapshot testing. That also means that we can start
    /// making UI before any other logic is done.
    @ObservedObject private var store: StoreOf<PokemonListViewModel>
    
    public init(store: StoreOf<PokemonListViewModel>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            Color(.background4).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: .spacing.double) {
                // Top logo, always visible
                Image(.pokemonLogo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, .spacing.double)
                
                switch store.state {
                // Idle
                case .idle:
                    EmptyView()
                    
                // Loading view
                case .loading(let text):
                    LoadingView(text: text)
                        .frame(maxHeight: .infinity)
                    
                // Error view
                case .error:
                    TryAgainView {
                        store.send(.loadNextPage)
                    }
                    .frame(maxHeight: .infinity)
                    
                // List
                case .loaded(let items, let hasMoreItems):
                    PokemonListComponent(items: items, hasMoreItems: hasMoreItems) { id in
                        store.send(.openDetails(id: id))
                    } onLoadMore: {
                        store.send(.loadNextPage)
                    }
                }
            }
        }
        .onFirstAppear {
            store.send(.loadNextPage)
        }
    }
}

// MARK: - List -

/// Separated list into its own component for better readability.
private struct PokemonListComponent: View {
    let items: [PokemonListItemView.State]
    let hasMoreItems: Bool
    let onTap: (_ id: String) -> Void
    let onLoadMore: () -> Void
    
    public var body: some View {
        List {
            Group {
                // Content inset to account for top gradient (see overlay)
                Rectangle().fill(.clear).frame(height: 10)
                
                // Items
                ForEach(items, id: \.self.id) { item in
                    PokemonListItemView(state: item)
                    // This is needed for tap to work on whole cell.
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onTap(item.id)
                        }
                }
                
                // Load More
                if hasMoreItems {
                    LoadMoreView()
                        .onAppear {
                            onLoadMore()
                        }
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: .spacing.double, bottom: 0, trailing: .spacing.double))
            .listRowSeparator(.hidden, edges: .all)
        }
        .listRowSpacing(.spacing.half)
        .listStyle(PlainListStyle())
        .environment(\.defaultMinListRowHeight, 10) // Needed because of top gradient.
        .overlay {
            // Top gradient.
            VStack {
                LinearGradient(gradient: Gradient(colors: [Color(.background4), .clear]), startPoint: .top, endPoint: .bottom)
                    .frame(height: 20)
                Spacer()
            }
        }
    }
}


