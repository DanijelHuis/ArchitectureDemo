//
//  Sizing.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation

public struct Sizing {
    public let borderNormal: CGFloat = 2
    public let cornerRadiusNormal: CGFloat = 4
}

public struct Spacing {
    public let half: CGFloat = 4
    public let normal: CGFloat = 8
    public let double: CGFloat = 16
    public let tripple: CGFloat = 24
    public let quad: CGFloat = 32
    
    /// Inter-item spacing for stack views.
    public let stackView: CGFloat = 16
    /// Padding around fullscreen view
    public let view: CGFloat = 24
}

public extension CGFloat {
    static let spacing = Spacing()
    static let sizing = Sizing()
}
