//
//  RSSChannelDetailsView.swift
//  Feedy
//
//  Created by Danijel Huis on 19.05.2024..
//

import Foundation
import SwiftUI
import CommonUI

@MainActor public struct RSSChannelDetailsView: View {
    @ObservedObject private var viewModel: ObservableSwiftUIViewModelOf<RSSChannelDetailsViewModel>
    
    public init(viewModel: any SwiftUIViewModelOf<RSSChannelDetailsViewModel>) {
        self.viewModel = .init(viewModel: viewModel)
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            Color.background2.edgesIgnoringSafeArea(.all)
            
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
                RSSChannelList(items: states) { link in
                    viewModel.send(.didTapOnRSSItem(link))
                }
                .refreshable {
                    await viewModel.sendAsync(.didInitiateRefresh)
                }
            }
        }
        .modifier(ifLet: viewModel.state.title) { $0.navigationTitle($1) }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            NavigationIconButton(iconSystemName: viewModel.state.isFavourite ? "star.fill" : "star") {
                viewModel.send(.toggleFavourites)
            }
        }
        .onFirstAppear {
            viewModel.send(.onFirstAppear)
        }
    }
}

// MARK: - List -

/// Separated list into its own component for better readability.
private struct RSSChannelList: View {
    let items: [RSSChannelItemListCell.State]
    let onTap: (_ link: URL?) -> Void
    
    public var body: some View {
        List() {
            Group {
                ForEach(items, id: \.self.id) { state in
                    RSSChannelItemListCell(state: state)
                        // This is needed for tap to work on whole cell.
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onTap(state.link)
                        }
                }
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
