//
//  GetRSSChannelUseCase.swift
//  Feedy
//
//  Created by Danijel Huis on 19.05.2024..
//

import Foundation

public protocol GetRSSChannelUseCase {
    func getRSSChannel(url: URL) async throws -> RSSChannel
}
