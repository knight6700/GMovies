//  MockMovieDetailsRepository.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import os
@testable import MovieDetails

final class MockMovieDetailsRepository: MovieDetailsRepository, Sendable {

    private struct State {
        var detailResult: Result<MovieDetail, Error>
        var getMovieDetailCallCount = 0
        var refreshMovieDetailCallCount = 0
        var lastRequestedID: Int?
    }

    private let state: OSAllocatedUnfairLock<State>

    var detailResult: Result<MovieDetail, Error> {
        get { state.withLock { $0.detailResult } }
        set { state.withLock { $0.detailResult = newValue } }
    }
    var getMovieDetailCallCount: Int { state.withLock { $0.getMovieDetailCallCount } }
    var refreshMovieDetailCallCount: Int { state.withLock { $0.refreshMovieDetailCallCount } }
    var lastRequestedID: Int? { state.withLock { $0.lastRequestedID } }

    init(
        detailResult: Result<MovieDetail, Error> = .success(
            MovieDetail(
                id: 99,
                title: "Dune",
                posterPath: "/d.jpg",
                releaseDate: "2021-10-22",
                genres: [Genre(id: 878, name: "Sci-Fi")],
                overview: "A desert planet.",
                homepage: nil,
                budget: 165_000_000,
                revenue: 401_000_000,
                status: "Released",
                runtime: 155,
                spokenLanguages: ["English"]
            )
        )
    ) {
        self.state = OSAllocatedUnfairLock(initialState: State(detailResult: detailResult))
    }

    func getMovieDetail(id: Int) async throws -> MovieDetail {
        let result = state.withLock { s -> Result<MovieDetail, Error> in
            s.lastRequestedID = id
            s.getMovieDetailCallCount += 1
            return s.detailResult
        }
        return try result.get()
    }

    func refreshMovieDetail(id: Int) async throws -> MovieDetail {
        let result = state.withLock { s -> Result<MovieDetail, Error> in
            s.lastRequestedID = id
            s.refreshMovieDetailCallCount += 1
            return s.detailResult
        }
        return try result.get()
    }
}
