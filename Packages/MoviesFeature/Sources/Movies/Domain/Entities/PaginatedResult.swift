//  PaginatedResult.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

public struct PaginatedResult<T: Sendable>: Sendable {

    public let items: [T]
    public let page: Int
    public let totalPages: Int

    public init(items: [T], page: Int, totalPages: Int) {
        self.items = items
        self.page = page
        self.totalPages = totalPages
    }
}
