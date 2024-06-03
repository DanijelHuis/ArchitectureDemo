//
//  DefaultRSSRepository.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import Foundation
import Domain

public class DefaultRSSRepository: RSSRepository {
    let remoteDataSource: RSSDataSource
    
    public convenience init(httpClient: HTTPClient) {
        self.init(remoteDataSource: RemoteRSSDataSource(httpClient: httpClient))
    }
    
    init(remoteDataSource: RSSDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    public func getRSSChannel(url: URL) async throws -> RSSChannel {
        try await remoteDataSource.getRSSChannel(url: url)
    }
}

extension DefaultRSSRepository: GetRSSChannelUseCase {}
