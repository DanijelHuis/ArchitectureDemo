//
//  TryAgainView.swift
//  
//
//  Created by Danijel Huis on 01.05.2024..
//

import SwiftUI

/// View with icon, error text and try again button.
struct TryAgainView: View {
    private let text: String
    private let tryAgainText: String
    private let tryAgainClosure: (() -> Void)?
    
    init(text: String = "common_error_occured_try_again".localized,
         tryAgainText: String = "common_try_again".localized,
         tryAgainClosure: (() -> Void)?) {
        self.text = text
        self.tryAgainText = tryAgainText
        self.tryAgainClosure = tryAgainClosure
    }
    
    var body: some View {
        VStack(spacing: .spacing.double) {
            Image(.iconError)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
            
            Text(text)
                .multilineTextAlignment(.center)
                .textStyle(.body1)
            
            Button(tryAgainText) {
                tryAgainClosure?()
            }
            .buttonStyle(CustomButtonStyle.action)
        }
        .padding(.horizontal, .spacing.quad)
    }
}

#Preview {
    VStack(spacing: 20) {
        TryAgainView(text: "short",
                     tryAgainText: "short",
                     tryAgainClosure: nil)
        
        TryAgainView(text: "long long long long long long long text. Error occurred, please try again...",
                     tryAgainText: "long long long long long long long long long long long",
                     tryAgainClosure: nil)
    }
}

