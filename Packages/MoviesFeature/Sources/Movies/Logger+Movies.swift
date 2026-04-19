//  Logger+Movies.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import OSLog
import Utilities

extension Logger {
    static let moviesDI = Logger.app("MoviesDI")
    static let moviesRepo = Logger.app("MoviesRepo")
    static let moviesStore = Logger.app("MoviesStore")
    static let movieList = Logger.app("MovieList")
    static let pagination = Logger.app("Pagination")
}
