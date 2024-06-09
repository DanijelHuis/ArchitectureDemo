//
//  TextFieldStyle.swift
//  Feedy
//
//  Created by Danijel Huis on 18.05.2024..
//

import Foundation
import SwiftUI

public struct StandardTextFieldStyle: TextFieldStyle {
    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .textStyle(Style.Text.body1)
            .padding(.spacing.double)
            .background(Color(.background3))
            .overlay(
                RoundedRectangle(cornerRadius: .sizing.cornerRadiusNormal)
                    .stroke(Color(.foreground1), lineWidth: .sizing.borderNormal)
            )
    }
}
