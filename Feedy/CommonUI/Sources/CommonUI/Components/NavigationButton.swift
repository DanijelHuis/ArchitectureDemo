//
//  NavigationButton.swift
//  Feedy
//
//  Created by Danijel Huis on 19.05.2024..
//

import Foundation
import SwiftUI

/// Styled buttons meant to be used in navigation bar.
public struct NavigationIconButton: View {
    let iconSystemName: String
    let action: () -> Void
    
    public init(iconSystemName: String, action: @escaping () -> Void) {
        self.iconSystemName = iconSystemName
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            action()
        }) {
            Image(systemName: iconSystemName)
                .renderingMode(.template)
        }
        .buttonStyle(Style.Button.navigation)
    }
}
