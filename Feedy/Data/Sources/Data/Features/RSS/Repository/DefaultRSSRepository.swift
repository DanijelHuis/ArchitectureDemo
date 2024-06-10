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
    
    public func getRSSChannels(historyItems: [RSSHistoryItem]) async -> [UUID: Result<RSSChannel, RSSChannelError>] {
        await withTaskGroup(of: (uuid: UUID, result: Result<RSSChannel, RSSChannelError>).self) { taskGroup in
            for historyItem in historyItems {
                taskGroup.addTask {
                    do {
                        let channel = try await self.getRSSChannel(url: historyItem.channelURL)
                        return (uuid: historyItem.id, result: .success(channel))
                    } catch {
                        return (uuid: historyItem.id, result: .failure(.failedToLoad))
                    }
                }
            }
            
            return await taskGroup.reduce(into: [UUID: Result<RSSChannel, RSSChannelError>]()) { partialResult, channelResult in
                partialResult[channelResult.uuid] = channelResult.result
            }
        }
    }
}

extension DefaultRSSRepository: GetRSSChannelUseCase {}
