//
//  CapsuleText.swift
//  
//
//  Created by Danijel Huis on 01.05.2024..
//

import SwiftUI

/// Simple text with capsule shaped background.
struct CapsuleText: View {
    private let text: String
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .textStyle(.body1)
            .multilineTextAlignment(.center)
            .padding(.horizontal, .spacing.tripple)
            .padding(.vertical, .spacing.half)
            .background {
                Capsule()
                    .fill(Color(.background2)).opacity(0.2)
            }
    }
}

#Preview {
    VStack {
        CapsuleText(text: "short")
        CapsuleText(text: "long long long long long long long long long long long long long ")
    }
}
