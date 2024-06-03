//
//  Sizing.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation

struct Sizing {
    let borderNormal: CGFloat = 2
    let cornerRadiusNormal: CGFloat = 4
}

struct Spacing {
    let half: CGFloat = 4
    let normal: CGFloat = 8
    let double: CGFloat = 16
    let tripple: CGFloat = 24
    let quad: CGFloat = 32
    
    /// Inter-item spacing for stack views.
    let stackView: CGFloat = 16
    /// Padding around fullscreen view
    let view: CGFloat = 24
}

extension CGFloat {
    static let spacing = Spacing()
    static let sizing = Sizing()
}
