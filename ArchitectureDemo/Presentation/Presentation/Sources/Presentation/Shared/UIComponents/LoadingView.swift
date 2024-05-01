//
//  LoadingView.swift
//
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation
import SwiftUI

/// Loading view with progress and text.
struct LoadingView: View {
    private let text: String
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        VStack(spacing: .spacing.double) {
            ProgressView()
                .progressViewStyle(.circular)
                .controlSize(.large)
                .tint(Color(.foreground2))
            
            Text(text)
                .textStyle(.body1)
                .multilineTextAlignment(.center)
        }
        .padding(.spacing.double)
    }
}

#Preview {
    LoadingView(text: "long long long long long long long long long long long long long long")
}

