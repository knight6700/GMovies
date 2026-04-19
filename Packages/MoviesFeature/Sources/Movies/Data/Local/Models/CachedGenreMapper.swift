//  CachedGenreMapper.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

struct CachedGenreMapper {
    static func map(_ cached: CachedGenre) -> Genre {
        Genre(id: cached.id, name: cached.name)
    }

    static func map(_ genre: Genre) -> CachedGenre {
        CachedGenre(id: genre.id, name: genre.name)
    }
}
