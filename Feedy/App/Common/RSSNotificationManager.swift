//
//  RSSNotificationManager.swift
//  Feedy
//
//  Created by Danijel Huis on 20.05.2024..
//

import Foundation

// e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.huis1"]
final class RSSNotificationManager {
    let taskIdentifier = "com.huis1"
    private let rssHistoryRepository: RSSHistoryRepository
    private let getRSSChannelsUseCase: GetRSSChannelsUseCase
    private let localNotificationManager: LocalNotificationManager
    private let updateLastReadItemIDUseCase: UpdateLastReadItemIDUseCase
    
    init(rssHistoryRepository: RSSHistoryRepository, getRSSChannelsUseCase: GetRSSChannelsUseCase, localNotificationManager: LocalNotificationManager, updateLastReadItemIDUseCase: UpdateLastReadItemIDUseCase) {
        self.rssHistoryRepository = rssHistoryRepository
        self.getRSSChannelsUseCase = getRSSChannelsUseCase
        self.localNotificationManager = localNotificationManager
        self.updateLastReadItemIDUseCase = updateLastReadItemIDUseCase
    }
    
    func reload() async throws {
        print("!!! Reload")
        // Take all subscribed history items
        guard let subscribedHistoryItems = try rssHistoryRepository.getRSSHistoryItems()?.filter({ $0.isSubscribed }) else { return }
        print("!!! Found following subscribed items: \(subscribedHistoryItems.map({ $0.channelURL.absoluteString }))")
        let channels = await getRSSChannelsUseCase.getRSSChannels(historyItems: subscribedHistoryItems)
        var channelTitles = [String]()
        
        for subscribedHistoryItem in subscribedHistoryItems {
            guard case let .success(channel) = channels[subscribedHistoryItem.id] else { continue }
            guard let channelLastItemID = channel.items.first?.guid else { continue }
            
            print("!!! channel \(subscribedHistoryItem.channelURL.absoluteString): \(subscribedHistoryItem.lastReadItemID) --- \(channel.items.first?.guid)")
            if subscribedHistoryItem.lastReadItemID != channelLastItemID {
                channelTitles.append(channel.title)
                
                // We can send now, even if notification fails to show we don't want to show notifications for old items.
                try updateLastReadItemIDUseCase.updateLastReadItemID(historyItemID: subscribedHistoryItem.id, lastItemID: channelLastItemID)
            }
        }
        guard !channelTitles.isEmpty else { return }
        let title = "Feedy"
        let body = "\("rss_notification_message".localized) \(channelTitles.joined(separator: ", "))"
        
        try await localNotificationManager.sendNotification(title: title, body: body)
    }
}

