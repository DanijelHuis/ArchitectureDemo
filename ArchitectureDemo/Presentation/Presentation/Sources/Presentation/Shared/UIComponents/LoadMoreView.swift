//
//  LoadMoreView.swift
//  
//
//  Created by Danijel Huis on 01.05.2024..
//

import SwiftUI

/// Load more control for the list.
struct LoadMoreView: View {
    private let text: String
    
    init(text: String = "common_loading".localized) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .textStyle(.body1)
            .multilineTextAlignment(.center)
            .padding(.spacing.double)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    LoadMoreView(text: "long long long long long long long long long long long long long long long")
}

