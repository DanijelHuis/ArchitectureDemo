//
//  RSSDataSource.swift
//  Feedy
//
//  Created by Danijel Huis on 18.05.2024..
//

import Foundation
import Domain

public protocol RSSDataSource {
    func getRSSChannel(url: URL) async throws -> RSSChannel
}
