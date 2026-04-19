//  PaginationControllerTests.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import Testing
import os
@testable import Movies

@Suite(.serialized)
struct PaginationControllerTests {

    @Test @MainActor
    func loadNextPage_appendsItems() async {
        let page1 = MovieFixtures.makeMovies(range: 1...10)
        let page2 = MovieFixtures.makeMovies(range: 11...20)
        let controller = PaginationController<Movie>(
            policy: PrefetchPaginationPolicy(threshold: 5)
        ) { _ in PaginatedResult(items: page2, page: 2, totalPages: 3) }
        controller.reset(items: page1, totalPages: 3)

        await controller.loadNextPageIfNeeded(after: page1[6].id)

        #expect(controller.currentPage == 2)
        #expect(controller.items.count == 20)
    }

    @Test @MainActor
    func loadNextPage_onFailure_setsPagingError() async {
        let page1 = MovieFixtures.makeMovies(range: 1...10)
        let controller = PaginationController<Movie>(
            policy: PrefetchPaginationPolicy(threshold: 5)
        ) { _ in throw URLError(.notConnectedToInternet) }
        controller.reset(items: page1, totalPages: 3)

        await controller.loadNextPageIfNeeded(after: page1[6].id)

        #expect(controller.pagingError != nil)
        #expect(controller.currentPage == 1)
    }

    @Test @MainActor
    func retry_afterFailure_loadsSuccessfully() async {
        let page1 = MovieFixtures.makeMovies(range: 1...10)
        let page2 = MovieFixtures.makeMovies(range: 11...20)
        let attempts = OSAllocatedUnfairLock(initialState: 0)
        let controller = PaginationController<Movie>(
            policy: PrefetchPaginationPolicy(threshold: 5)
        ) { _ in
            let n = attempts.withLock { $0 += 1; return $0 }
            if n == 1 { throw URLError(.notConnectedToInternet) }
            return PaginatedResult(items: page2, page: 2, totalPages: 3)
        }
        controller.reset(items: page1, totalPages: 3)

        await controller.loadNextPageIfNeeded(after: page1[6].id)
        #expect(controller.pagingError != nil)

        await controller.retryNextPage()
        #expect(controller.pagingError == nil)
        #expect(controller.items.count == 20)
    }
}
