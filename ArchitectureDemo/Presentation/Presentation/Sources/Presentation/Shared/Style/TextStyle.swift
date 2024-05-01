//
//  TextStyle.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import SwiftUI

// MARK: - App definitions -

extension TextStyle {
    static let heading1 = TextStyle(font: .heading1, color: .foreground2)
    static let heading2 = TextStyle(font: .heading2, color: .foreground2)
    static let body1 = TextStyle(font: .body1, color: .foreground2)
    static let listTitle = TextStyle(font: .heading2, color: .foreground2)
}

// MARK: - TextStyle -

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
