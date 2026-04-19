//  CachedMovieMapper.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation

struct CachedMovieMapper {
    static func map(_ cached: CachedMovie) -> Movie {
        Movie(
            id: cached.id,
            title: cached.title,
            posterPath: cached.posterPath,
            releaseYear: cached.releaseYear,
            genreIDs: cached.genreIDs,
            overview: cached.overview,
            voteAverage: cached.voteAverage
        )
    }

    static func map(_ movie: Movie) -> CachedMovie {
        CachedMovie(
            id: movie.id,
            title: movie.title,
            posterPath: movie.posterPath,
            releaseYear: movie.releaseYear,
            genreIDs: movie.genreIDs,
            overview: movie.overview,
            voteAverage: movie.voteAverage
        )
    }

    static func update(_ cached: CachedMovie, from movie: Movie) {
        cached.title = movie.title
        cached.posterPath = movie.posterPath
        cached.releaseYear = movie.releaseYear
        cached.genreIDs = movie.genreIDs
        cached.overview = movie.overview
        cached.voteAverage = movie.voteAverage
        cached.updatedAt = .now
    }
}
