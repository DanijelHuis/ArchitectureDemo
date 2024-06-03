//
//  TextStyle.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import SwiftUI

struct TextStyle {
    let font: FontResource
    let color: ColorResource
}

// MARK: - TextStyle + SwiftUI -

extension View {
    func textStyle(_ style: TextStyle) -> some View {
        modifier(TextStyleViewModifier(style: style))
    }
}

struct TextStyleViewModifier: ViewModifier {
    let style: TextStyle
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color(style.color))
            .font(Font(resource: style.font))
    }
}
