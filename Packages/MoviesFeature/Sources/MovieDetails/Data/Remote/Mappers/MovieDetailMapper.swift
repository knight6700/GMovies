//  MovieDetailMapper.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

struct MovieDetailMapper {
    static func map(_ dto: MovieDetailDTO) -> MovieDetail {
        MovieDetail(
            id: dto.id,
            title: dto.title,
            posterPath: dto.posterPath,
            releaseDate: dto.releaseDate,
            genres: dto.genres.map(GenreMapper.map),
            overview: dto.overview,
            homepage: dto.homepage,
            budget: dto.budget,
            revenue: dto.revenue,
            status: dto.status,
            runtime: dto.runtime,
            spokenLanguages: dto.spokenLanguages.map(\.englishName)
        )
    }
}
