//
//  GetRSSChannelsUseCase.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import Foundation
import Combine

public protocol GetRSSChannelsUseCase {
    var output: AnyPublisher<[RSSChannelResponse], Never> { get }
    func getRSSChannels() async throws
}
