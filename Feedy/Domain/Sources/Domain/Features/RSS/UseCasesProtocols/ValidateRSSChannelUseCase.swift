//
//  ValidateRSSChannelUseCase.swift
//  Feedy
//
//  Created by Danijel Huis on 18.05.2024..
//

import Foundation

public protocol ValidateRSSChannelUseCase {
    func validateRSSChannel(url: URL) async -> Bool
}
