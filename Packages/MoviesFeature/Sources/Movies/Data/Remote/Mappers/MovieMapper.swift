//  MovieMapper.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

struct MovieMapper {
    static func map(_ dto: MovieDTO) -> Movie {
        let year = dto.releaseDate.flatMap { $0.count >= 4 ? Int($0.prefix(4)) : nil }
        return Movie(
            id: dto.id,
            title: dto.title,
            posterPath: dto.posterPath,
            releaseYear: year,
            genreIDs: dto.genreIDs,
            overview: dto.overview,
            voteAverage: dto.voteAverage
        )
    }
}

struct DiscoverMoviesResponseMapper {
    static func map(_ response: DiscoverMoviesResponseDTO) -> PaginatedResult<Movie> {
        PaginatedResult(
            items: response.results.map(MovieMapper.map),
            page: response.page,
            totalPages: response.totalPages
        )
    }
}
