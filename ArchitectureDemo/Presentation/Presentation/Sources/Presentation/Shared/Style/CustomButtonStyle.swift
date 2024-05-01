//
//  CustomButtonStyle.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation
import SwiftUI

// MARK: - App definitions -

extension CustomButtonStyle {
    static let action = CustomButtonStyle(font: Font(resource: .body1),
                                          foregroundColor: Color(.foreground2),
                                          backgroundColor: Color(.background2).opacity(0.25),
                                          roundingStyle: .round,
                                          padding: .init(top: 10, leading: 20, bottom: 10, trailing: 20))
}

// MARK: - CustomButtonStyle -

struct CustomButtonStyle {
    let font: Font?
    let foregroundColor: Color?
    let backgroundColor: Color?
    let roundingStyle: RoundingStyle?
    let padding: EdgeInsets
    
    enum RoundingStyle {
        case round
    }
}

// MARK: - Conforming CustomButtonStyle to ButtonStyle -

extension CustomButtonStyle: ButtonStyle {
    /// This is called by ButtonStyle, we get access to label and isPressed property. Here we apply button style and apply label style to layout title (and icon optionally).
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
        // Font
            .font(font)
        
        // This is needed for button to change height when title size is increased.
            .fixedSize(horizontal: false, vertical: true)
        
        // Foreground
            .modifier(ifLet: foregroundColor) { $0.foregroundColor($1) }
        
        // Padding
            .padding(padding)
        
        // Background
            .modifier {
                if let backgroundColor = backgroundColor {
                    let backgroundColor = configuration.isPressed ? backgroundColor.opacity(0.5) : backgroundColor
                    $0.background(backgroundColor)
                } else {
                    // This is needed for gestures to work if no background (or background is clear color).
                    $0.contentShape(Rectangle())
                }
            }
        
        // Rounding
            .modifier(ifLet: roundingStyle) { renderRoundingStyle(content: $0, roundingStyle: $1) }
        
        // Other
            .multilineTextAlignment(.center)
    }
    
    @ViewBuilder private func renderRoundingStyle(content: some View, roundingStyle: CustomButtonStyle.RoundingStyle) -> some View {
        switch roundingStyle {
        case .round:
            content
                .clipShape(Capsule())
        }
    }
}

