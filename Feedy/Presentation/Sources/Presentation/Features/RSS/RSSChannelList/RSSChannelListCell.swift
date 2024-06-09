//
//  RSSChannelListCell.swift
//  Feedy
//
//  Created by Danijel Huis on 18.05.2024..
//

import Foundation
import SwiftUI
import CommonUI

@MainActor public struct RSSChannelListCell: View {
    private let state: State
    
    public init(state: State) {
        self.state = state
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: .spacing.stackView) {
            // Image
            if let imageResource = state.imageResource {
                AsyncImage(resource: imageResource) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 60, maxHeight: 60)
                } placeholder: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 60, maxHeight: 60)
                }
                .padding(.top, 4)   // To align with text
            }
            
            // Title and description
            VStack(alignment: .leading, spacing: .spacing.half) {
                // Title
                Text(state.title)
                    .textStyle(Style.Text.heading4)
                    .lineLimit(3)
                
                // Description
                Text(state.description)
                    .textStyle(Style.Text.body1)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(spacing: .spacing.normal) {
                if state.isFavourite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.foreground1)
                        .textStyle(Style.Text.heading4)
                }
            }
        }
        .padding(.spacing.normal)
    }
}

extension RSSChannelListCell {
    public struct State: Equatable {
        let historyItemID: UUID
        let title: String
        let description: String
        let imageResource: AsyncImageResource?
        let isFavourite: Bool

    }
}

