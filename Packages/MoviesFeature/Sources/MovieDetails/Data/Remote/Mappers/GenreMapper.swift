//  GenreMapper.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

struct GenreMapper {
    static func map(_ dto: GenreDTO) -> Genre {
        Genre(id: dto.id, name: dto.name)
    }
}
