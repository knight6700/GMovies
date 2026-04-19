//  LocalSnapshot.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation

public struct LocalSnapshot<Value: Sendable>: Sendable {
    public let value: Value
    public let cachedAt: Date

    public init(value: Value, cachedAt: Date) {
        self.value = value
        self.cachedAt = cachedAt
    }

    public func isExpired(maxAge: TimeInterval, now: Date = .now) -> Bool {
        now.timeIntervalSince(cachedAt) > maxAge
    }
}

extension LocalSnapshot: CacheSnapshot {}
