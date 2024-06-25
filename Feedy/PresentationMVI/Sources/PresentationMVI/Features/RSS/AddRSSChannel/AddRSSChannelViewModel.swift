//
//  AddRSSChannelViewModel.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import Foundation
import Domain
import CommonUI

@MainActor @Observable 
public final class AddRSSChannelViewModel: SwiftUIViewModel {
    // Dependencies
    private let validateRSSChannelUseCase: ValidateRSSChannelUseCase
    private let addRSSHistoryItemUseCase: AddRSSHistoryItemUseCase
    public let effectManager: EffectManager
    // Other
    public private(set) var state: State = State()
    public var onFinished: (() -> Void)?

    public init(validateRSSChannelUseCase: ValidateRSSChannelUseCase, addRSSHistoryItemUseCase: AddRSSHistoryItemUseCase, effectManager: EffectManager) {
        self.validateRSSChannelUseCase = validateRSSChannelUseCase
        self.addRSSHistoryItemUseCase = addRSSHistoryItemUseCase
        self.effectManager = effectManager
    }
    
    deinit {
        print("Deinit \(type(of: self))")   //@DEBUG
    }
    
    public func send(_ action: Action) {
        switch action {
            
        case .didChangeChannelURLText(let url):
            state.channelURL = url
            // If error state and text is changed then put it into idle (that removes error message).
            guard case .error = state.status else { return }
            state.status = .idle
            
        case .didTapAddButton:
            // Check if invalid url.
            guard let url = URL(string: state.channelURL) else {
                state.status = .error(message: "rss_add_invalid_url".localized)
                return
            }
            
            effectManager.runTask {
                self.state.status = .validating
                
                // Check if we can fetch and decode RSS channel.
                let isValid = await self.validateRSSChannelUseCase.validateRSSChannel(url: url)
                
                if isValid {
                    do {
                        try await self.addRSSHistoryItemUseCase.addRSSHistoryItem(channelURL: url)
                        self.onFinished?()
                    } catch {
                        if (error as? RSSHistoryRepositoryError) == RSSHistoryRepositoryError.urlAlreadyExists {
                            self.state.status = .error(message: "rss_add_url_exists".localized)
                        } else {
                            self.state.status = .error(message: "rss_add_failed_to_add".localized)
                        }
                    }
                } else {
                    self.state.status = .error(message: "rss_add_failed_to_validate".localized)
                }
            }
        }
    }
}

// MARK: - State & Action -

extension AddRSSChannelViewModel {
    public struct State {
        let title = "rss_add_title".localized
        let placeholder = "rss_add_url_placeholder".localized
        let buttonTitle = "rss_add_button".localized
        var channelURL: String
        var status: ViewStatus
                
        public init(channelURL: String = "", status: AddRSSChannelViewModel.ViewStatus = ViewStatus.idle) {
            self.channelURL = channelURL
            self.status = status
        }
    }
    
    public enum ViewStatus: Equatable {
        case idle
        case validating
        case error(message: String)
    }
    
    public enum Action: Equatable {
        case didChangeChannelURLText(_ value: String)
        case didTapAddButton
    }
}
