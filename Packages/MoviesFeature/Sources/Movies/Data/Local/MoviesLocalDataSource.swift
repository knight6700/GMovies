//  MoviesLocalDataSource.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Persistence

public protocol MoviesLocalDataSource: Sendable {
    func saveMovies(_ movies: [Movie], page: Int, totalPages: Int) async throws
    func loadMovies(page: Int) async throws -> LocalSnapshot<PaginatedResult<Movie>>
    func saveGenres(_ genres: [Genre]) async throws
    func loadGenres() async throws -> LocalSnapshot<[Genre]>
}
