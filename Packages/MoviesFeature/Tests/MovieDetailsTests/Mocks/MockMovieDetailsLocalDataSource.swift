//  MockMovieDetailsLocalDataSource.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import os
import Persistence
@testable import MovieDetails

final class MockMovieDetailsLocalDataSource: MovieDetailsLocalDataSource, Sendable {
    private struct State {
        var savedDetail: MovieDetail?
        var saveDetailError: Error?
        var detailResult: LocalSnapshot<MovieDetail?> = LocalSnapshot(value: nil, cachedAt: .now)
    }

    private let state = OSAllocatedUnfairLock(initialState: State())

    var savedDetail: MovieDetail? { state.withLock { $0.savedDetail } }
    var saveDetailError: Error? {
        get { state.withLock { $0.saveDetailError } }
        set { state.withLock { $0.saveDetailError = newValue } }
    }

    var detailResult: LocalSnapshot<MovieDetail?> {
        get { state.withLock { $0.detailResult } }
        set { state.withLock { $0.detailResult = newValue } }
    }

    func saveMovieDetail(_ detail: MovieDetail) async throws {
        try state.withLock { state in
            if let error = state.saveDetailError {
                throw error
            }
            state.savedDetail = detail
        }
    }
    func loadMovieDetail(id _: Int) async throws -> LocalSnapshot<MovieDetail?> {
        detailResult
    }
}
