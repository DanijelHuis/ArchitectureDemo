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
    static let subheading1 = FontResource(name: .primary, size: 10, weight: .regular, style: .subheadline)
    static let heading4 = FontResource(name: .primary, size: 14, weight: .bold, style: .title)
    static let body1 = FontResource(name: .primary, size: 14, weight: .regular, style: .body)
    static let button1 = FontResource(name: .primary, size: 14, weight: .black, style: .body)
    static let navigation = FontResource(name: .primary, size: 14, weight: .regular, style: .body)
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
        case .primary: return ".AppleSystemUIFont"
        }
    }
}

// MARK: - Font + FontResource -

extension Font {
    init(resource: FontResource) {
        self = .custom(resource.name.family, size: resource.size, relativeTo: resource.style).weight(resource.weight)
    }
}
