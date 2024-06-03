//
//  RSSChannelItemListCell.swift
//  Feedy
//
//  Created by Danijel Huis on 19.05.2024..
//

import Foundation
import Foundation
import SwiftUI
import Kingfisher

@MainActor public struct RSSChannelItemListCell: View {
    private let state: State
    
    public init(state: State) {
        self.state = state
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: .spacing.normal) {
            // Image and date
            if let imageURL = state.imageURL {
                // Kingfisher because it has much better loading performance.
                KFImage(imageURL)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 130)
            }
            
            // Title and description
            VStack(alignment: .leading, spacing: .spacing.half) {
                if let publishDate = state.publishDate {
                    Text(publishDate)
                        .textStyle(Style.Text.subheading1)
                }
                
                // Title
                if let title = state.title {
                    Text(title)
                        .textStyle(Style.Text.heading4)
                        .lineLimit(3)
                }
                
                if let description = state.description {
                    // Description
                    Text(description)
                        .textStyle(Style.Text.body1)
                        .lineLimit(2)
                }
            }
            Spacer()
        }
        .padding(.spacing.normal)
    }
}

extension RSSChannelItemListCell {
    public struct State: Identifiable, Equatable {
        public let id: String
        let link: URL?   // Not part of the view but we use it as ID
        let title: String?
        let publishDate: String?
        let description: String?
        let imageURL: URL?
    }
}
