//  CacheState.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation

public protocol CacheSnapshot: Sendable {
    associatedtype Value: Sendable

    var value: Value { get }
    func isExpired(maxAge: TimeInterval, now: Date) -> Bool
}

public enum CacheState<Value: Sendable>: Sendable {
    case unavailable
    case fresh(Value)
    case stale(Value)
}

public enum CacheStateResolver {
    public static func resolve<Snapshot: CacheSnapshot>(
        for snapshot: Snapshot?,
        strategy: CacheFetchStrategy = .standard,
        maxAge: TimeInterval,
        now: Date
    ) -> CacheState<Snapshot.Value> {
        guard let snapshot else {
            return .unavailable
        }

        if strategy == .forceRefresh {
            return .stale(snapshot.value)
        }

        if snapshot.isExpired(maxAge: maxAge, now: now) {
            return .stale(snapshot.value)
        }

        return .fresh(snapshot.value)
    }
}
