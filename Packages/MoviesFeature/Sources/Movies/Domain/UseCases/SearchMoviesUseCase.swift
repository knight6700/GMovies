//  SearchMoviesUseCase.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation

public struct SearchMoviesUseCase: Sendable {

    public init() { /* Stateless use case — no dependencies */ }

    public func execute(movies: [Movie], query: String) -> [Movie] {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedQuery.isEmpty else { return movies }
        return movies.filter { $0.title.localizedCaseInsensitiveContains(normalizedQuery) }
    }
}
