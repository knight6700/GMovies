//  MoviesRepository.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

public protocol PopularMoviesRepository: Sendable {
    func getPopularMovies(page: Int) async throws -> PaginatedResult<Movie>
    func refreshPopularMovies(page: Int) async throws -> PaginatedResult<Movie>
}

public protocol GenreRepository: Sendable {
    func getGenres() async throws -> [Genre]
    func refreshGenres() async throws -> [Genre]
}

