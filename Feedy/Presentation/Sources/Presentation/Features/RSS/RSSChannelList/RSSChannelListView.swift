//
//  RSSChannelListView.swift
//  Feedy
//
//  Created by Danijel Huis on 18.05.2024..
//

import SwiftUI

@MainActor public struct RSSChannelListView: View {
    @ObservedObject private var viewModel: ObservableSwiftUIViewModelOf<RSSChannelListViewModel>
    
    public init(viewModel: ObservableSwiftUIViewModelOf<RSSChannelListViewModel>) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            Color(.background2).edgesIgnoringSafeArea(.all)
            
            switch viewModel.state.status {
                
            // Loading
            case .loading(let text):
                LoadingView(text: text)
                    .frame(maxHeight: .infinity)
                
            // Empty
            case .empty(let text):
                EmptyDataView(text: text)
                    .frame(maxHeight: .infinity)
            
            // Loaded
            case .loaded(let states):
                RSSChannelList(items: states) { id in
                    viewModel.send(.didSelectItem(id))
                } onDidDeleteItem: { id in
                    viewModel.send(.didTapRemoveHistoryItem(id))
                }
                .refreshable {
                    await viewModel.sendAsync(.didInitiateRefresh)
                }

            // Error
            case .error(let text):
                ErrorView(text: text)
                    .frame(maxHeight: .infinity)
            }
        }
        .navigationTitle(viewModel.state.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            NavigationIconButton(iconSystemName: viewModel.state.isShowingFavourites ? "star.fill" : "star") {
                viewModel.send(.toggleFavourites)
            }
            .accessibilityIdentifier("list_favourite")

            NavigationIconButton(iconSystemName: "plus.app") {
                viewModel.send(.didTapAddChannelButton)
            }
            .accessibilityIdentifier("list_add")
        }
        .onFirstAppear {
            viewModel.send(.onFirstAppear)
        }
    }
}

// MARK: - List -

/// Separated list into its own component for better readability.
private struct RSSChannelList: View {
    let items: [RSSChannelListCell.State]
    let onDidSelectItem: (_ id: UUID) -> Void
    let onDidDeleteItem: (_ id: UUID) -> Void
    
    public var body: some View {
        List() {
            Group {
                ForEach(items, id: \.self.historyItemID) { state in
                    RSSChannelListCell(state: state)
                        // This is needed for tap to work on whole cell.
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onDidSelectItem(state.historyItemID)
                        }
                }
                .onDelete(perform: { indexSet in
                    for index in indexSet {
                        let item = items[index]
                        onDidDeleteItem(item.historyItemID)
                    }
                })
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listSectionSeparator(.hidden)
            .listRowSeparator(.automatic, edges: .bottom)
        }
        .listStyle(PlainListStyle())
        .environment(\.defaultMinListRowHeight, .spacing.normal)
    }
}
