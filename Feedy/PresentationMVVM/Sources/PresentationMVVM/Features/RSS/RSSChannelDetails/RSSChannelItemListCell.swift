//
//  RSSChannelItemListCell.swift
//  Feedy
//
//  Created by Danijel Huis on 11.06.2024..
//

import Foundation
import Foundation
import SwiftUI
import Domain
import Kingfisher
import CommonUI

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

// This is tested in RSSChannelDetailsViewModelTests.
extension RSSChannelItemListCell {
    public struct State: Identifiable, Equatable {
        // Data
        var rssItem: RSSItem
        public var id: String { rssItem.guid ?? UUID().uuidString }
        var link: URL? { rssItem.link }
        var title: String? { rssItem.title }
        var publishDate: String? { rssItem.pubDate.map { TimeFormatter(locale: Container.locale, timeZone: Container.timeZone).string(from: $0) } }
        var description: String? { rssItem.description }
        var imageURL: URL? { rssItem.imageURL }
    }
}
