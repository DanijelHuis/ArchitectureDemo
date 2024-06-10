//
//  Container.swift
//  Feedy
//
//  Created by Danijel Huis on 18.05.2024..
//

import Foundation
import URLSessionNetworking
import Domain
import Data

/// Poor man's dependency injection.
struct Container {
    static var rssHTTPClient: DefaultHTTPClient {
        DefaultHTTPClient(requestBuilder: URLSessionRequestBuilder(),
                          requestAuthorizer: nil,
                          requestService: URLSessionRequestService())
    }
    
    static var validateRSSChannelUseCase: ValidateRSSChannelUseCase  {
        DefaultValidateRSSChannelUseCase(repository: Container.rssRepository)
    }
        
    static var rssRepository: DefaultRSSRepository {
        DefaultRSSRepository(httpClient: Container.rssHTTPClient)
    }
    
    static var rssHistoryRepository: DefaultRSSHistoryRepository {
        DefaultRSSHistoryRepository(persistenceManager: UserDefaultsPersistenceManager())
    }
    
    // MARK: - Shared -
    
    static var sharedRSSHistoryManager = RSSHistoryManager(historyRepository: DefaultRSSHistoryRepository(persistenceManager: UserDefaultsPersistenceManager()), rssRepository: rssRepository)
}
