//  InMemoryMovieDetailsLocalDataSource.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import Persistence

public actor InMemoryMovieDetailsLocalDataSource: MovieDetailsLocalDataSource {

    private var detailsByID: [Int: LocalSnapshot<MovieDetail?>] = [:]

    public init() { /* No-op — in-memory store requires no setup */ }

    public func saveMovieDetail(_ detail: MovieDetail) async throws {
        detailsByID[detail.id] = LocalSnapshot(value: detail, cachedAt: .now)
    }

    public func loadMovieDetail(id: Int) async throws -> LocalSnapshot<MovieDetail?> {
        detailsByID[id] ?? LocalSnapshot(value: nil, cachedAt: .distantPast)
    }
}
