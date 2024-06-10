//
//  RemoveRSSHistoryItemUseCase.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import Foundation

public protocol RemoveRSSHistoryItemUseCase {
    func removeRSSHistoryItem(_ historyItemID: UUID) async throws
}
