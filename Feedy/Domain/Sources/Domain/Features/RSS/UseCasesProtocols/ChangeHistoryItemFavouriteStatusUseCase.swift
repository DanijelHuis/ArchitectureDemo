//
//  ChangeHistoryItemFavouriteStatusUseCase.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import Foundation

public protocol ChangeHistoryItemFavouriteStatusUseCase {
    func changeFavouriteStatus(historyItemID: UUID, isFavourite: Bool) async throws
}
