//
//  ErrorView.swift
//  Feedy
//
//  Created by Danijel Huis on 19.05.2024..
//

import Foundation
import SwiftUI

/// Styled view with icon, error text and try again button.
struct ErrorView: View {
    private let text: String
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        VStack(spacing: .spacing.stackView) {
            Image(.iconError)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
            
            Text(text)
                .multilineTextAlignment(.center)
                .textStyle(Style.Text.body1)
        }
        .padding(.horizontal, .spacing.view)
    }
}

#Preview {
    VStack(spacing: 20) {
        ErrorView(text: "short")
        ErrorView(text: "long long long long long long long text. Error occurred, please try again...")
    }
}

