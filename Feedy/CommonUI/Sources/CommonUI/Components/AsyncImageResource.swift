//
//  AsyncImageResource.swift
//  Feedy
//
//  Created by Danijel Huis on 18.05.2024..
//

import Foundation
import SwiftUI

/// This is used as input to AsyncImage that needs placeholder image.
public struct AsyncImageResource: Equatable {
    let url: URL?
    let placeholderSystemName: String
    
    public init(url: URL?, placeholderSystemName: String) {
        self.url = url
        self.placeholderSystemName = placeholderSystemName
    }
}

// MARK: - AsyncImage -

public extension AsyncImage {
    init<I, P>(resource: AsyncImageResource,
               @ViewBuilder content: @escaping (Image) -> (I),
               @ViewBuilder placeholder: @escaping (Image) -> (P)) where Content == _ConditionalContent<I, P>, I: View, P: View {
        self.init(url: resource.url) { image in
            content(image)
        } placeholder: {
            placeholder(Image(systemName: resource.placeholderSystemName))
        }
    }
}
