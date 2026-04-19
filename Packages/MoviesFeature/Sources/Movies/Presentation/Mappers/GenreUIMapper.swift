//  GenreUIMapper.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

struct GenreUIMapper {
    static func map(_ genre: Genre) -> GenreUIModel {
        GenreUIModel(
            id: genre.id,
            name: genre.name
        )
    }
}
