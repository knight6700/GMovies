//  CachePolicy.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation

public enum CachePolicy {
    public static func resolve<Snapshot: CacheSnapshot>(
        isConnected: Bool,
        strategy: CacheFetchStrategy = .standard,
        maxAge: TimeInterval,
        now: Date,
        offlineError: @autoclosure @escaping @Sendable () -> Error,
        snapshot: @escaping @Sendable () async -> Snapshot?,
        cachedValue: @escaping @Sendable (_ fallbackError: Error) async throws -> Snapshot.Value,
        networkValue: @escaping @Sendable () async throws -> Snapshot.Value
    ) async throws -> Snapshot.Value {
        if !isConnected {
            return try await cachedValue(offlineError())
        }

        switch CacheStateResolver.resolve(
            for: await snapshot(),
            strategy: strategy,
            maxAge: maxAge,
            now: now
        ) {
        case .fresh(let value):
            return value

        case .stale(let value):
            do {
                return try await networkValue()
            } catch {
                return value
            }

        case .unavailable:
            do {
                return try await networkValue()
            } catch {
                return try await cachedValue(error)
            }
        }
    }
}
