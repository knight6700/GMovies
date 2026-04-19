//  MockMoviesLocalDataSource.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import os
import Persistence
@testable import Movies

final class MockMoviesLocalDataSource: MoviesLocalDataSource, Sendable {
    private struct State {
        var savedMovies: [Movie] = []
        var savedGenres: [Genre] = []
        var saveMoviesError: Error?
        var saveGenresError: Error?
        var moviesResult: Result<LocalSnapshot<PaginatedResult<Movie>>, Error> = .success(
            LocalSnapshot(
                value: PaginatedResult(items: [], page: 1, totalPages: 1),
                cachedAt: .now
            )
        )
        var genresResult: Result<LocalSnapshot<[Genre]>, Error> = .success(
            LocalSnapshot(value: [], cachedAt: .now)
        )
    }

    private let state = OSAllocatedUnfairLock(initialState: State())

    var savedMovies: [Movie] { state.withLock { $0.savedMovies } }
    var savedGenres: [Genre] { state.withLock { $0.savedGenres } }
    var saveMoviesError: Error? {
        get { state.withLock { $0.saveMoviesError } }
        set { state.withLock { $0.saveMoviesError = newValue } }
    }
    var saveGenresError: Error? {
        get { state.withLock { $0.saveGenresError } }
        set { state.withLock { $0.saveGenresError = newValue } }
    }

    var moviesResult: Result<LocalSnapshot<PaginatedResult<Movie>>, Error> {
        get { state.withLock { $0.moviesResult } }
        set { state.withLock { $0.moviesResult = newValue } }
    }
    var genresResult: Result<LocalSnapshot<[Genre]>, Error> {
        get { state.withLock { $0.genresResult } }
        set { state.withLock { $0.genresResult = newValue } }
    }

    func saveMovies(_ movies: [Movie], page _: Int, totalPages _: Int) async throws {
        try state.withLock { state in
            if let error = state.saveMoviesError {
                throw error
            }
            state.savedMovies = movies
        }
    }
    func loadMovies(page _: Int) async throws -> LocalSnapshot<PaginatedResult<Movie>> {
        try moviesResult.get()
    }
    func saveGenres(_ genres: [Genre]) async throws {
        try state.withLock { state in
            if let error = state.saveGenresError {
                throw error
            }
            state.savedGenres = genres
        }
    }
    func loadGenres() async throws -> LocalSnapshot<[Genre]> {
        try genresResult.get()
    }
}
