//
//  RSSChannelDetailsView.swift
//  Feedy
//
//  Created by Danijel Huis on 11.06.2024..
//

import Foundation
import SwiftUI
import CommonUI

@MainActor public struct RSSChannelDetailsView: View {
    @State private var viewModel: RSSChannelDetailsViewModel
    
    public init(viewModel: RSSChannelDetailsViewModel) {
        self.viewModel =  viewModel
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            Color.background2.edgesIgnoringSafeArea(.all)
            
            switch viewModel.status {
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
                    viewModel.didTapOnRSSItem(link: link)
                }
                .refreshable {
                    await viewModel.didInitiateRefresh()
                }
            }
        }
        .modifier(ifLet: viewModel.title) { $0.navigationTitle($1) }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            NavigationIconButton(iconSystemName: viewModel.isFavourite ? "star.fill" : "star") {
                viewModel.toggleFavourites()
            }
        }
        .onFirstAppear {
            viewModel.onFirstAppear()
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
