//
//  CustomButtonStyle.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation
import SwiftUI

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
        CustomButton(style: self, configuration: configuration)
    }
}

fileprivate struct CustomButton: View {
    @Environment(\.isEnabled) private var isEnabled: Bool
    let style: CustomButtonStyle
    let configuration: ButtonStyleConfiguration
    
    var body: some View {
        configuration.label
            // Font
            .font(style.font)
        
            // This is needed for button to change height when title size is increased.
            .fixedSize(horizontal: false, vertical: true)
        
            // Foreground
            .modifier(ifLet: style.foregroundColor) { $0.foregroundColor($1) }
            // Padding
            .padding(style.padding)
        
            // Background
            .modifier {
                
                if let backgroundColor = style.backgroundColor {
                    let backgroundColor = (configuration.isPressed || !isEnabled) ? backgroundColor.opacity(0.5) : backgroundColor
                    $0.background(backgroundColor)

                } else {
                    // This is needed for gestures to work if no background (or background is clear color).
                    $0.contentShape(Rectangle())
                }
            }
        
            // Rounding
            .modifier(ifLet: style.roundingStyle) { renderRoundingStyle(content: $0, roundingStyle: $1) }
        
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
