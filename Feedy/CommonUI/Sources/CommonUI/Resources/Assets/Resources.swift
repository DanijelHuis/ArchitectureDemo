//
//  Resources.swift
//
//
//  Created by Danijel Huis on 09.06.2024..
//

import Foundation
import SwiftUI

/**
 IMPORTANT: We have to do this because auto-generated ColorResource and ImageResource are internal and cannot be accessed from different packages.
 */
extension Color {
    public static var foreground1 = Color(.foreground1)
    public static var foreground2 = Color(.foreground2)
    public static var foreground3 = Color(.foreground3)
    public static var background1 = Color(.background1)
    public static var background2 = Color(.background2)
    public static var background3 = Color(.background3)
    public static var background4 = Color(.background4)
    public static var error = Color(.error)
}

extension Image {
    public static var iconError = Image(.iconError)
}
