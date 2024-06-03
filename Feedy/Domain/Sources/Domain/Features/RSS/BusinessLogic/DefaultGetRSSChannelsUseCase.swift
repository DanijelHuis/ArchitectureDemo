//
//  DefaultGetRSSChannelsUseCase.swift
//  Feedy
//
//  Created by Danijel Huis on 18.05.2024..
//

import Foundation

public final class DefaultGetRSSChannelsUseCase: GetRSSChannelsUseCase {
    private let repository: RSSRepository
    
    public init(repository: RSSRepository) {
        self.repository = repository
    }
    
    /// Fetches channels concurrently.
    public func getRSSChannels(historyItems: [RSSHistoryItem]) async -> [UUID: Result<RSSChannel, RSSChannelError>] {
        await withTaskGroup(of: (uuid: UUID, result: Result<RSSChannel, RSSChannelError>).self) { taskGroup in
            for historyItem in historyItems {
                taskGroup.addTask {
                    do {
                        let channel = try await self.repository.getRSSChannel(url: historyItem.channelURL)
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
