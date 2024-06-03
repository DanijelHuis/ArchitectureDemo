//
//  ProgressViewStyle.swift
//  Feedy
//
//  Created by Danijel Huis on 18.05.2024..
//

import Foundation
import SwiftUI

struct CircularProgressViewStyle: ProgressViewStyle {
    @ViewBuilder func makeBody(configuration: Configuration) -> some View {
        ProgressView()
            .progressViewStyle(.circular)
            .controlSize(.large)
            .tint(Color(.foreground1))
    }
}

