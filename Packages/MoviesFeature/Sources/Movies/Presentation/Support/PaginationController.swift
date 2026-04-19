//  PaginationController.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import OSLog
import Utilities


@MainActor
@Observable
public final class PaginationController<Item: Identifiable & Sendable> {

    public private(set) var items: [Item] = []
    public private(set) var isLoadingMore: Bool = false
    public private(set) var pagingError: String?

    private(set) var currentPage = 1
    private(set) var totalPages = 1

    private let policy: any PaginationPolicy
    private let fetch: @MainActor (Int) async throws -> PaginatedResult<Item>
    private var resetGeneration = 0

    public init(
        policy: any PaginationPolicy = PrefetchPaginationPolicy(),
        fetch: @escaping @MainActor (Int) async throws -> PaginatedResult<Item>
    ) {
        self.policy = policy
        self.fetch = fetch
    }

    public func reset(items: [Item], totalPages: Int) {
        resetGeneration += 1
        self.items = items
        currentPage = 1
        self.totalPages = totalPages
        pagingError = nil
        isLoadingMore = false
    }

    public func loadNextPageIfNeeded(after itemID: Item.ID) async {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        guard shouldLoadNext(currentIndex: index) else { return }
        await performLoadNext()
    }

    /// Retries loading the next page after a previous failure.
    /// Unlike `loadNextPageIfNeeded`, this bypasses the policy threshold check
    /// because the user explicitly requested a retry.
    public func retryNextPage() async {
        guard !isLoadingMore, currentPage < totalPages else { return }
        await performLoadNext()
    }

    private func shouldLoadNext(currentIndex: Int) -> Bool {
        policy.shouldLoadNext(
            PaginationContext(
                currentIndex: currentIndex,
                totalItems: items.count,
                currentPage: currentPage,
                totalPages: totalPages,
                isLoadingMore: isLoadingMore,
                hasError: pagingError != nil
            )
        )
    }

    private func performLoadNext() async {
        isLoadingMore = true
        pagingError = nil
        let nextPage = currentPage + 1
        let generation = resetGeneration
        Logger.pagination.info("loadNext page=\(nextPage)")

        do {
            let paginated = try await fetch(nextPage)
            try Task.checkCancellation()
            guard generation == resetGeneration else { return }
            currentPage = nextPage
            isLoadingMore = false
            pagingError = nil
            items = (items + paginated.items).uniquedByID()
            Logger.pagination.info("loadNext page=\(nextPage) loaded items=\(paginated.items.count)")
        } catch is CancellationError {
            guard generation == resetGeneration else { return }
            isLoadingMore = false
        } catch {
            guard generation == resetGeneration else { return }
            isLoadingMore = false
            Logger.pagination.error("loadNext page=\(nextPage) failed: \(error.localizedDescription, privacy: .public)")
            pagingError = error.localizedDescription
        }
    }
}
