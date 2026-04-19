//  MovieDetailsLocalDataSource.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Persistence

public protocol MovieDetailsLocalDataSource: Sendable {
    func saveMovieDetail(_ detail: MovieDetail) async throws
    func loadMovieDetail(id: Int) async throws -> LocalSnapshot<MovieDetail?>
}
