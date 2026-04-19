//  MovieDTO.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

struct MovieDTO: Decodable {
    let id: Int
    let title: String
    let posterPath: String?
    let releaseDate: String?
    let genreIDs: [Int]
    let overview: String
    let voteAverage: Double

    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath  = "poster_path"
        case releaseDate = "release_date"
        case genreIDs    = "genre_ids"
        case voteAverage = "vote_average"
    }
}
