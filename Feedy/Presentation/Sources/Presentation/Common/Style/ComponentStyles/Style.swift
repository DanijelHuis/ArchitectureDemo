//
//  Style.swift
//  Feedy
//
//  Created by Danijel Huis on 18.05.2024..
//

import Foundation
import SwiftUI

/// Contains all styles in the app.
enum Style {
    enum Text {
        static let subheading1 = TextStyle(font: .subheading1, color: .foreground3)
        static let heading4 = TextStyle(font: .heading4, color: .foreground3)
        static let body1 = TextStyle(font: .body1, color: .foreground3)
        static let error1 = TextStyle(font: .body1, color: .error)
    }
    
    enum Button {
        static let action = CustomButtonStyle(font: Font(resource: .button1),
                                              foregroundColor: Color(.foreground2),
                                              backgroundColor: Color(.background4),
                                              roundingStyle: .round,
                                              padding: .init(top: 16, leading: 30, bottom: 16, trailing: 30))
        
        static let navigation = CustomButtonStyle(font: Font(resource: .navigation),
                                                  foregroundColor: Color(.foreground1),
                                                  backgroundColor: nil,
                                                  roundingStyle: .none,
                                                  padding: .init(top: 0, leading: 8, bottom: 0, trailing: 8))
    }
    
    enum TextField {
        static let standard = StandardTextFieldStyle()
    }
    
    enum ProgressView {
        static let standard = CircularProgressViewStyle()
    }
}
