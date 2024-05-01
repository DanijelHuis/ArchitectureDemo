//
//  FontResource.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation
import SwiftUI

// MARK: - App definitions -

extension FontResource {
    static let heading1 = FontResource(name: .primary, size: 42, weight: .regular, style: .headline)
    static let heading2 = FontResource(name: .primary, size: 26, weight: .regular, style: .headline)
    static let heading3 = FontResource(name: .primary, size: 20, weight: .regular, style: .headline)
    static let body1 = FontResource(name: .primary, size: 15, weight: .regular, style: .body)
}

// MARK: - FontResource -

struct FontResource {
    let name: FontName
    let size: Double
    let weight: Font.Weight
    /// This is used for relative sizing (dynamic font).
    let style: Font.TextStyle
}

enum FontName {
    case primary
    
    var family: String {
        switch self {
        case .primary: return "American Typewriter"
        }
    }
}

// MARK: - Font + FontResource -

extension Font {
    init(resource: FontResource) {
        self = .custom(resource.name.family, size: resource.size, relativeTo: resource.style).weight(resource.weight)
    }
}
