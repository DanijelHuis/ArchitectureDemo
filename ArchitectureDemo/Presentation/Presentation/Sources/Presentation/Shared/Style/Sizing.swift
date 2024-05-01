//
//  Sizing.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation

struct Sizing {
    
}

struct Spacing {
    let half: CGFloat = 4
    let normal: CGFloat = 8
    let double: CGFloat = 16
    let tripple: CGFloat = 24
    let quad: CGFloat = 32
    
    let stackView: CGFloat = 16
}

extension CGFloat {
    static let spacing = Spacing()
    static let sizing = Sizing()
}
