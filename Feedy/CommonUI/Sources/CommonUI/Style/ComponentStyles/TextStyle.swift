//
//  TextStyle.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import SwiftUI

public struct TextStyle {
    public let font: FontResource
    public let color: Color
}

// MARK: - TextStyle + SwiftUI -

public extension View {
    func textStyle(_ style: TextStyle) -> some View {
        modifier(TextStyleViewModifier(style: style))
    }
}

public struct TextStyleViewModifier: ViewModifier {
    public let style: TextStyle
    
    public func body(content: Content) -> some View {
        content
            .foregroundColor(style.color)
            .font(Font(resource: style.font))
    }
}
