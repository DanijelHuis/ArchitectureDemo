//
//  EmptyDataView.swift
//  Feedy
//
//  Created by Danijel Huis on 19.05.2024..
//

import SwiftUI

/// Styled view that is used when there is no content on the screen. Shows icon and text.
struct EmptyDataView: View {
    private let text: String
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        VStack() {
            Image(systemName: "folder.badge.questionmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 100, maxHeight: 100)
            
            Text(text)
                .textStyle(Style.Text.body1)
                .multilineTextAlignment(.center)
        }
        .padding(.spacing.view)
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    VStack {
        EmptyDataView(text: "short")
        EmptyDataView(text: "long long long long long long long long long long long long long long")
    }
}

