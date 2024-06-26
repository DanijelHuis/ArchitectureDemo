//
//  AddRSSChannelViewModel.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import Foundation
import Domain
import CommonUI

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
        
        effectManager.runTask {
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
    private(set) var status = ViewStatus.idle
    
    // We allow channelURL to be modified from outside, this is acceptable in original MVVM even though we usually didn't allow it.
    var channelURL = "" {
        didSet {
            // If error state and text is changed then put it into idle (that removes error message).
            guard case .error = status else { return }
            status = .idle
        }
    }
}

// MARK: - State & Action -

extension AddRSSChannelViewModel {
    public enum ViewStatus: Equatable {
        case idle
        case validating
        case error(message: String)
    }
}
