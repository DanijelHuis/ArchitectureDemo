//
//  DefaultValidateRSSChannelUseCase.swift
//  Feedy
//
//  Created by Danijel Huis on 18.05.2024..
//

import Foundation

public final class DefaultValidateRSSChannelUseCase: ValidateRSSChannelUseCase {
    private let repository: RSSRepository
    
    public init(repository: RSSRepository) {
        self.repository = repository
    }
    
    /// It returns true if it can fetch end decode RSS channel.
    public func validateRSSChannel(url: URL) async -> Bool {
        do {
            _ = try await repository.getRSSChannel(url: url)
            return true
        } catch {
            return false
        }
    }
}
