//  MockMoviesRepository.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import os
@testable import Movies

final class MockMoviesRepository: PopularMoviesRepository, GenreRepository, Sendable {

    private struct State {
        var moviesResult: Result<PaginatedResult<Movie>, Error>
        var genresResult: Result<[Genre], Error>
        var pageHandler: (@Sendable (Int) -> Result<PaginatedResult<Movie>, Error>)?
        var lastRequestedPage: Int?
        var getPopularMoviesCallCount = 0
        var getGenresCallCount = 0
        var refreshPopularMoviesCallCount = 0
        var refreshGenresCallCount = 0
    }

    private let state: OSAllocatedUnfairLock<State>

    var moviesResult: Result<PaginatedResult<Movie>, Error> {
        get { state.withLock { $0.moviesResult } }
        set { state.withLock { $0.moviesResult = newValue } }
    }
    var genresResult: Result<[Genre], Error> {
        get { state.withLock { $0.genresResult } }
        set { state.withLock { $0.genresResult = newValue } }
    }
    var pageHandler: (@Sendable (Int) -> Result<PaginatedResult<Movie>, Error>)? {
        get { state.withLock { $0.pageHandler } }
        set { state.withLock { $0.pageHandler = newValue } }
    }

    var lastRequestedPage: Int? { state.withLock { $0.lastRequestedPage } }
    var getPopularMoviesCallCount: Int { state.withLock { $0.getPopularMoviesCallCount } }
    var getGenresCallCount: Int { state.withLock { $0.getGenresCallCount } }
    var refreshPopularMoviesCallCount: Int { state.withLock { $0.refreshPopularMoviesCallCount } }
    var refreshGenresCallCount: Int { state.withLock { $0.refreshGenresCallCount } }

    init(
        moviesResult: Result<PaginatedResult<Movie>, Error> = .success(
            PaginatedResult(
                items: [MovieFixtures.makeMovie()],
                page: 1,
                totalPages: 10
            )
        ),
        genresResult: Result<[Genre], Error> = .success([Genre(id: 16, name: "Animation")])
    ) {
        self.state = OSAllocatedUnfairLock(
            initialState: State(
                moviesResult: moviesResult,
                genresResult: genresResult
            )
        )
    }

    func getPopularMovies(page: Int) async throws -> PaginatedResult<Movie> {
        let result = state.withLock { s -> Result<PaginatedResult<Movie>, Error> in
            s.lastRequestedPage = page
            s.getPopularMoviesCallCount += 1
            return s.pageHandler?(page) ?? s.moviesResult
        }
        return try result.get()
    }

    func getGenres() async throws -> [Genre] {
        let result = state.withLock { s -> Result<[Genre], Error> in
            s.getGenresCallCount += 1
            return s.genresResult
        }
        return try result.get()
    }

    func refreshPopularMovies(page: Int) async throws -> PaginatedResult<Movie> {
        let result = state.withLock { s -> Result<PaginatedResult<Movie>, Error> in
            s.lastRequestedPage = page
            s.refreshPopularMoviesCallCount += 1
            return s.pageHandler?(page) ?? s.moviesResult
        }
        return try result.get()
    }

    func refreshGenres() async throws -> [Genre] {
        let result = state.withLock { s -> Result<[Genre], Error> in
            s.refreshGenresCallCount += 1
            return s.genresResult
        }
        return try result.get()
    }
}
