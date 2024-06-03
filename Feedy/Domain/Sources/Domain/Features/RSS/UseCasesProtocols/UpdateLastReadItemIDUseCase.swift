//
//  UpdateLastReadItemIDUseCase.swift
//
//
//  Created by Danijel Huis on 20.05.2024..
//

import Foundation

public protocol UpdateLastReadItemIDUseCase {
    func updateLastReadItemID(historyItemID: UUID, lastItemID: String) throws
}
