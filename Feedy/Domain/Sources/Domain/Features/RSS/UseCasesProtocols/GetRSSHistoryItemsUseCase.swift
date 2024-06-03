//
//  UpdateRSSHistoryItemsUseCase.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import Foundation
import Combine

public protocol GetRSSHistoryItemsUseCase {
    var output: AnyPublisher<RSSHistoryEvent, Never> { get }
    func getRSSHistoryItems() throws
}
