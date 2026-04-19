//  CachedMovieDetailMapper.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

struct CachedMovieDetailMapper {
    static func map(_ cached: CachedMovieDetail) -> MovieDetail {
        let genres = zip(cached.genreIDs, cached.genreNames).map { Genre(id: $0, name: $1) }
        return MovieDetail(
            id: cached.id,
            title: cached.title,
            posterPath: cached.posterPath,
            releaseDate: cached.releaseDate,
            genres: genres,
            overview: cached.overview,
            homepage: cached.homepage,
            budget: cached.budget,
            revenue: cached.revenue,
            status: cached.status,
            runtime: cached.runtime,
            spokenLanguages: cached.spokenLanguages
        )
    }

    static func map(_ detail: MovieDetail) -> CachedMovieDetail {
        CachedMovieDetail(
            id: detail.id,
            title: detail.title,
            posterPath: detail.posterPath,
            releaseDate: detail.releaseDate,
            genreIDs: detail.genres.map(\.id),
            genreNames: detail.genres.map(\.name),
            overview: detail.overview,
            homepage: detail.homepage,
            budget: detail.budget,
            revenue: detail.revenue,
            status: detail.status,
            runtime: detail.runtime,
            spokenLanguages: detail.spokenLanguages
        )
    }
}
