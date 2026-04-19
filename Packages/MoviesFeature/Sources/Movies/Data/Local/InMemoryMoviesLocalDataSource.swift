//  InMemoryMoviesLocalDataSource.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import Persistence

public actor InMemoryMoviesLocalDataSource: MoviesLocalDataSource {

    private var moviesByPage: [Int: LocalSnapshot<PaginatedResult<Movie>>] = [:]
    private var genresSnapshot = LocalSnapshot<[Genre]>(value: [], cachedAt: .distantPast)

    public init() { /* No-op — in-memory store requires no setup */ }

    public func saveMovies(_ movies: [Movie], page: Int, totalPages: Int) async throws {
        moviesByPage[page] = LocalSnapshot(
            value: PaginatedResult(items: movies, page: page, totalPages: totalPages),
            cachedAt: .now
        )
    }

    public func loadMovies(page: Int) async throws -> LocalSnapshot<PaginatedResult<Movie>> {
        moviesByPage[page]
            ?? LocalSnapshot(
                value: PaginatedResult(items: [], page: page, totalPages: 1),
                cachedAt: .distantPast
            )
    }

    public func saveGenres(_ genres: [Genre]) async throws {
        genresSnapshot = LocalSnapshot(value: genres, cachedAt: .now)
    }

    public func loadGenres() async throws -> LocalSnapshot<[Genre]> {
        genresSnapshot
    }
}
