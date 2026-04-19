//  GenreMapper.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

struct GenresResponseMapper {
    static func map(_ response: GenresResponseDTO) -> [Genre] {
        response.genres.map { Genre(id: $0.id, name: $0.name) }
    }
}
