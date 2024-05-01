//
//  ArchitectureDemoApp.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import SwiftUI
import Presentation

@main
struct ArchitectureDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    private let navigator = Navigator()
    private let pokemonsList: any View
    
    init() {
        AppStyle.setupAppStyle()
        pokemonsList = AppCoordinator(navigator: navigator).view(.pokemons(.list))
    }
    
    var body: some Scene {
        WindowGroup {
            MainView(navigator: navigator, rootView: pokemonsList)
        }
    }
}
