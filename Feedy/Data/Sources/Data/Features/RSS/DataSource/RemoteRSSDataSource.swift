//
//  RemoteRSSRepository.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import Foundation
import Domain

class RemoteRSSDataSource: RSSDataSource {
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    /// Fetches RSS channel from remote URL.
    func getRSSChannel(url: URL) async throws -> RSSChannel {
        let request = try await httpClient.buildRequest(method: .get, url: url, query: nil, headers: nil, body: nil)
        let response = try await httpClient.performRequest(request, decodedTo: RemoteRSSChannelResponse.self)
        return response.channel.mapped(rssURL: url)
    }
}

// MARK: - Remote to Domain mapping -

private extension RemoteRSSChannel {
    func mapped(rssURL: URL) -> RSSChannel {
        let items = item?.map({ $0.mapped() }) ?? []
        // Sorting by pubDate.
        let sortedItems = items.sorted { $0.pubDate >>> $1.pubDate}
        
        return RSSChannel(title: title,
                          description: description,
                          imageURL: image?.url,
                          items: sortedItems)
    }
}

extension RemoteRSSItem {
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = "EEE, dd MMMM yyyy HH:mm:ss Z"
        return dateFormatter
    }
    
    func mapped() -> RSSItem {
        // Parsing date manually because we don't want parser to fail if some date format is wrong (spec not really clear).
        var pubDateObject: Date?
        if let pubDate {
            pubDateObject = Self.dateFormatter.date(from: pubDate)
        }
        
        return RSSItem(guid: guid,
                       title: title,
                       description: description,
                       link: link,
                       imageURL: enclosure?.imageURL,
                       pubDate: pubDateObject)
    }
}

extension RemoteRSSItem.Enclosure {
    var imageURL: URL? {
        guard type.hasPrefix("image") else { return nil }
        return url
    }
}
