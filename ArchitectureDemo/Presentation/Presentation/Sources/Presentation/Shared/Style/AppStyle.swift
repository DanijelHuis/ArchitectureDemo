//
//  AppStyle.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation
import UIKit

public struct AppStyle {
    
    /// Styles navigation bar
    public static func setupAppStyle() {
        let buttonFont = UIFont(name: FontName.primary.family, size: 16) ?? .systemFont(ofSize: 16)
        let color = UIColor(resource: .foreground2)
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        
        // Back button
        let barButtonAppearance = UIBarButtonItemAppearance()
        barButtonAppearance.normal.titleTextAttributes = [
            .font: buttonFont,
            .foregroundColor: color
        ]
        navigationBarAppearance.backButtonAppearance = barButtonAppearance
        // Back button color, must be set last
        UIBarButtonItem.appearance().tintColor = UIColor.black
    }
}
