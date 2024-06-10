//
//  ErrorView.swift
//  Feedy
//
//  Created by Danijel Huis on 19.05.2024..
//

import Foundation
import SwiftUI

/// Styled view with icon, error text and try again button.
public struct ErrorView: View {
    private let text: String
    private let retryText: String
    private let onRetry: () -> Void
    
    public init(text: String, retryText: String, onRetry: @escaping () -> Void) {
        self.text = text
        self.retryText = retryText
        self.onRetry = onRetry
    }
    
    public var body: some View {
        VStack(spacing: .spacing.stackView) {
            Image(.iconError)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
            
            Text(text)
                .multilineTextAlignment(.center)
                .textStyle(Style.Text.body1)
            
            Button(retryText) {
                onRetry()
            }
            .buttonStyle(Style.Button.action)
        }
        .padding(.horizontal, .spacing.view)
    }
}

#Preview {
    VStack(spacing: 20) {
        ErrorView(text: "short", retryText: "retry") {}
        ErrorView(text: "long long long long long long long text. Error occurred, please try again...", retryText: "retry") {}
    }
}
