//  FilterMoviesByGenreUseCase.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

public struct FilterMoviesByGenreUseCase: Sendable {

    public init() { /* Stateless use case — no dependencies */ }

    public func execute(movies: [Movie], genreID: Int?) -> [Movie] {
        guard let genreID else { return movies }
        return movies.filter { $0.genreIDs.contains(genreID) }
    }
}
