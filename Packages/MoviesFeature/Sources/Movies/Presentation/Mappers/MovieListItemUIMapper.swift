//  MovieListItemUIMapper.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Utilities

struct MovieListItemUIMapper {
    private let imageURLBuilder: any ImageURLBuilding

    init(imageURLBuilder: any ImageURLBuilding) {
        self.imageURLBuilder = imageURLBuilder
    }

    func map(_ movie: Movie) -> MovieListItemUIModel {
        MovieListItemUIModel(
            id: movie.id,
            title: movie.title,
            posterURL: imageURLBuilder.url(for: movie.posterPath, size: .w185),
            rating: movie.voteAverage,
            year: movie.releaseYear.map(String.init)
        )
    }
}
