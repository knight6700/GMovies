//  FakeSnapshot.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
@testable import Persistence

struct FakeSnapshot: CacheSnapshot {
    let value: String
    let cachedAt: Date

    func isExpired(maxAge: TimeInterval, now: Date) -> Bool {
        now.timeIntervalSince(cachedAt) > maxAge
    }
}
