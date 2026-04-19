//  CacheStateResolverTests.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import Testing
@testable import Persistence

@Suite("CacheStateResolver")
struct CacheStateResolverTests {

    private let now = Date()

    @Test
    func freshCache() {
        let snapshot = FakeSnapshot(value: "cached", cachedAt: now.addingTimeInterval(-30))
        let state = CacheStateResolver.resolve(for: snapshot, maxAge: 60, now: now)

        guard case .fresh(let value) = state else {
            Issue.record("Expected .fresh, got \(state)")
            return
        }
        #expect(value == "cached")
    }

    @Test
    func staleCache() {
        let snapshot = FakeSnapshot(value: "old", cachedAt: now.addingTimeInterval(-120))
        let state = CacheStateResolver.resolve(for: snapshot, maxAge: 60, now: now)

        guard case .stale(let value) = state else {
            Issue.record("Expected .stale, got \(state)")
            return
        }
        #expect(value == "old")
    }

    @Test
    func noSnapshot() {
        let state: CacheState<String> = CacheStateResolver.resolve(
            for: nil as FakeSnapshot?, maxAge: 60, now: now
        )
        guard case .unavailable = state else {
            Issue.record("Expected .unavailable, got \(state)")
            return
        }
    }

    @Test
    func exactBoundaryIsFresh() {
        let snapshot = FakeSnapshot(value: "edge", cachedAt: now.addingTimeInterval(-60))
        let state = CacheStateResolver.resolve(for: snapshot, maxAge: 60, now: now)

        guard case .fresh = state else {
            Issue.record("Expected .fresh at exact boundary")
            return
        }
    }

    @Test
    func forceRefreshMakesFreshStale() {
        let snapshot = FakeSnapshot(value: "fresh", cachedAt: now)
        let state = CacheStateResolver.resolve(for: snapshot, strategy: .forceRefresh, maxAge: 60, now: now)

        guard case .stale(let value) = state else {
            Issue.record("Expected .stale with forceRefresh")
            return
        }
        #expect(value == "fresh")
    }
}
