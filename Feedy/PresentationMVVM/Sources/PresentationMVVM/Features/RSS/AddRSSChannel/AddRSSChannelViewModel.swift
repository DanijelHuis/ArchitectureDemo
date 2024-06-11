//
//  AddRSSChannelViewModel.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import Foundation
import Domain

@Observable @MainActor public final class AddRSSChannelViewModel {
    // Dependencies
    private let validateRSSChannelUseCase: ValidateRSSChannelUseCase
    private let addRSSHistoryItemUseCase: AddRSSHistoryItemUseCase
    public let effectManager: EffectManager
    // Other
    public var onFinished: (() -> Void)?
    
    public init(validateRSSChannelUseCase: ValidateRSSChannelUseCase, addRSSHistoryItemUseCase: AddRSSHistoryItemUseCase, effectManager: EffectManager) {
        self.validateRSSChannelUseCase = validateRSSChannelUseCase
        self.addRSSHistoryItemUseCase = addRSSHistoryItemUseCase
        self.effectManager = effectManager
    }
    
    // MARK: - Actions -
    
    func didTapAddButton() {
        // Check if invalid url.
        guard let url = URL(string: channelURL) else {
            status = .error(message: "rss_add_invalid_url".localized)
            return
        }
        
        effectManager.run {
            self.status = .validating
            
            // Check if we can fetch and decode RSS channel.
            let isValid = await self.validateRSSChannelUseCase.validateRSSChannel(url: url)
            
            if isValid {
                do {
                    try await self.addRSSHistoryItemUseCase.addRSSHistoryItem(channelURL: url)
                    self.onFinished?()
                } catch {
                    if (error as? RSSHistoryRepositoryError) == RSSHistoryRepositoryError.urlAlreadyExists {
                        self.status = .error(message: "rss_add_url_exists".localized)
                    } else {
                        self.status = .error(message: "rss_add_failed_to_add".localized)
                    }
                }
            } else {
                self.status = .error(message: "rss_add_failed_to_validate".localized)
            }
        }
    }
    
    // MARK: - View state -
    
    let title = "rss_add_title".localized
    let placeholder = "rss_add_url_placeholder".localized
    let buttonTitle = "rss_add_button".localized
    var channelURL = ""
    var status = ViewStatus.idle
}

// MARK: - State & Action -

extension AddRSSChannelViewModel {
    public enum ViewStatus: Equatable {
        case idle
        case validating
        case error(message: String)
    }
}
