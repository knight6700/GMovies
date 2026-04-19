//  PaginationPolicy.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

/// Snapshot of pagination state used by the policy to decide whether to load more.
public struct PaginationContext: Equatable, Sendable {
    public let currentIndex: Int
    public let totalItems: Int
    public let currentPage: Int
    public let totalPages: Int
    public let isLoadingMore: Bool
    public let hasError: Bool

    public init(
        currentIndex: Int,
        totalItems: Int,
        currentPage: Int,
        totalPages: Int,
        isLoadingMore: Bool,
        hasError: Bool
    ) {
        self.currentIndex = currentIndex
        self.totalItems = totalItems
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.isLoadingMore = isLoadingMore
        self.hasError = hasError
    }
}

public protocol PaginationPolicy: Sendable {
     func shouldLoadNext(_ context: PaginationContext) -> Bool
}

public struct PrefetchPaginationPolicy: PaginationPolicy {
    public let threshold: Int

    public init(threshold: Int = 5) {
        self.threshold = threshold
    }

    public func shouldLoadNext(_ context: PaginationContext) -> Bool {
        context.currentIndex >= context.totalItems - threshold
            && context.currentPage < context.totalPages
            && !context.isLoadingMore
            && !context.hasError
    }
}
