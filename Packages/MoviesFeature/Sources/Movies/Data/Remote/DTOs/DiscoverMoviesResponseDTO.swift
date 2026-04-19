//  DiscoverMoviesResponseDTO.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

struct DiscoverMoviesResponseDTO: Decodable {
    let page: Int
    let results: [MovieDTO]
    let totalPages: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
    }
}
