//
//  AddRSSHistoryItemUseCase.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import Foundation

public protocol AddRSSHistoryItemUseCase {
    func addRSSHistoryItem(channelURL: URL) throws
}
