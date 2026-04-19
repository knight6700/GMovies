//  CachePolicyTests.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import Testing
@testable import Persistence

@Suite("CachePolicy")
struct CachePolicyTests {

    private let now = Date()

    @Test
    func freshCacheSkipsNetwork() async throws {
        let result = try await CachePolicy.resolve(
            isConnected: true, maxAge: 60, now: now,
            offlineError: URLError(.notConnectedToInternet),
            snapshot: { FakeSnapshot(value: "cached", cachedAt: self.now.addingTimeInterval(-10)) },
            cachedValue: { _ in "cached" },
            networkValue: { Issue.record("Should not call network"); return "network" }
        )

        #expect(result == "cached")
    }

    @Test
    func staleCacheRefreshesFromNetwork() async throws {
        let result = try await CachePolicy.resolve(
            isConnected: true, maxAge: 60, now: now,
            offlineError: URLError(.notConnectedToInternet),
            snapshot: { FakeSnapshot(value: "old", cachedAt: self.now.addingTimeInterval(-120)) },
            cachedValue: { _ in "old" },
            networkValue: { "fresh" }
        )

        #expect(result == "fresh")
    }

    @Test
    func staleCacheFallbackOnNetworkFailure() async throws {
        let result = try await CachePolicy.resolve(
            isConnected: true, maxAge: 60, now: now,
            offlineError: URLError(.notConnectedToInternet),
            snapshot: { FakeSnapshot(value: "stale", cachedAt: self.now.addingTimeInterval(-120)) },
            cachedValue: { _ in "stale" },
            networkValue: { throw URLError(.timedOut) }
        )

        #expect(result == "stale")
    }

    @Test
    func noCacheFetchesNetwork() async throws {
        let result = try await CachePolicy.resolve(
            isConnected: true, maxAge: 60, now: now,
            offlineError: URLError(.notConnectedToInternet),
            snapshot: { nil as FakeSnapshot? },
            cachedValue: { throw $0 },
            networkValue: { "network" }
        )

        #expect(result == "network")
    }

    @Test
    func noCacheAndNetworkFailsThrows() async {
        do {
            _ = try await CachePolicy.resolve(
                isConnected: true, maxAge: 60, now: now,
                offlineError: URLError(.notConnectedToInternet),
                snapshot: { nil as FakeSnapshot? },
                cachedValue: { throw $0 },
                networkValue: { throw URLError(.timedOut) }
            )
            Issue.record("Expected error")
        } catch {
            #expect(error is URLError)
        }
    }

    @Test
    func offlineReturnsCachedValue() async throws {
        let result = try await CachePolicy.resolve(
            isConnected: false, maxAge: 60, now: now,
            offlineError: URLError(.notConnectedToInternet),
            snapshot: { FakeSnapshot(value: "cached", cachedAt: self.now) },
            cachedValue: { _ in "cached" },
            networkValue: { Issue.record("Should not call network"); return "x" }
        )

        #expect(result == "cached")
    }

    @Test
    func offlineNoCacheThrows() async {
        do {
            _ = try await CachePolicy.resolve(
                isConnected: false, maxAge: 60, now: now,
                offlineError: URLError(.notConnectedToInternet),
                snapshot: { nil as FakeSnapshot? },
                cachedValue: { throw $0 },
                networkValue: { Issue.record("Should not call network"); return "x" }
            )
            Issue.record("Expected error")
        } catch let error as URLError {
            #expect(error.code == .notConnectedToInternet)
        } catch {
            Issue.record("Expected URLError, got \(error)")
        }
    }

    @Test
    func forceRefreshBypassesFreshCache() async throws {
        let result = try await CachePolicy.resolve(
            isConnected: true, strategy: .forceRefresh, maxAge: 60, now: now,
            offlineError: URLError(.notConnectedToInternet),
            snapshot: { FakeSnapshot(value: "fresh", cachedAt: self.now) },
            cachedValue: { _ in "fresh" },
            networkValue: { "refreshed" }
        )

        #expect(result == "refreshed")
    }
}
