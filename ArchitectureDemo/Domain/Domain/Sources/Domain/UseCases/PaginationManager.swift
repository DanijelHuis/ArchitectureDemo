//
//  PaginationManager.swift
//  
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation

/// Handles paging.
///
/// How to use it:
/// 1. Use `firstPage` to fetch your first page.
/// 2. After page is fetched call `addPage(...)`.
/// 3. Use `nextPage` to fetch next page.
class PaginationManager {
    /// Page size, also called limit.
    let pageSize: Int
    /// Holds loaded pages.
    private(set) var pages: [Page] = []
    /// Total item count on the backend.
    var totalItemCount: Int?
    
    init(pageSize: Int) {
        self.pageSize = pageSize
    }
    
    /// Returns first page (0, pageSize)
    var firstPage: Page { Page(offset: 0, limit: pageSize) }
    
    /// Returns next page if:
    /// - pages (page data) were added before
    /// - totalItemCount was set and (lastPage.offset + limit) < totalItemCount
    var nextPage: Page? {
        guard let lastPage = pages.last else { return nil }
        guard let totalItemCount = totalItemCount else { return nil }
        let nextPageOffset = lastPage.offset + pageSize
        guard nextPageOffset < totalItemCount else { return nil }
        return Page(offset: nextPageOffset, limit: pageSize)
    }
    
    /// Adds page and sets total item count (from backend).
    func addPage(_ page: Page, totalItemCount: Int) {
        if page.offset == 0 { removeAllPages() }
        self.totalItemCount = totalItemCount
        pages.append(page)
    }
    
    func removeAllPages() {
        pages.removeAll()
        totalItemCount = nil
    }
}

// MARK: - Entities -

/// Describes page but doesn't hold data.
public struct Page: Equatable {
    let offset: Int
    let limit: Int
}

