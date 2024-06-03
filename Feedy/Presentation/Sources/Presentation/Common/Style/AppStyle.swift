//
//  AppStyle.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import Foundation
import UIKit
import SwiftUI

public struct AppStyle {
    
    /// Styles navigation bar
    public static func setupAppStyle() {
        // We cannot make UIFont from font so we do it like this.
        let titleFont = UIFont(name: FontName.primary.family, size: 20)?.withTrait(trait: .traitBold) ?? .systemFont(ofSize: 16)
        let buttonFont = UIFont(name: FontName.primary.family, size: 16) ?? .systemFont(ofSize: 16)
        let navigationBackgroundColor = UIColor(resource: .background1)
        let navigationTitleColor = UIColor(resource: .foreground3)
        let navigationItemColor = UIColor(resource: .foreground1)
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = navigationBackgroundColor
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.titleTextAttributes = [
            .font: titleFont,
            .foregroundColor: navigationTitleColor
        ]
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().tintColor = navigationItemColor

        // Back button
        let barButtonAppearance = UIBarButtonItemAppearance()
        barButtonAppearance.normal.titleTextAttributes = [
            .font: buttonFont,
            .foregroundColor: navigationItemColor
        ]
        navigationBarAppearance.backButtonAppearance = barButtonAppearance
        // Back button color, must be set last
        UIBarButtonItem.appearance().tintColor = navigationItemColor
    }

}

private extension UIFont {
    func withTrait(trait: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(trait) else { return self }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
