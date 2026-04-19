//  MovieDetailDTO.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

struct MovieDetailDTO: Decodable {
    let id: Int
    let title: String
    let posterPath: String?
    let releaseDate: String?
    let genres: [GenreDTO]
    let overview: String
    let homepage: String?
    let budget: Int
    let revenue: Int
    let status: String
    let runtime: Int?
    let spokenLanguages: [SpokenLanguageDTO]

    enum CodingKeys: String, CodingKey {
        case id, title, overview, homepage, budget, revenue, status, runtime, genres
        case posterPath      = "poster_path"
        case releaseDate     = "release_date"
        case spokenLanguages = "spoken_languages"
    }
}

struct SpokenLanguageDTO: Decodable {
    let englishName: String

    enum CodingKeys: String, CodingKey {
        case englishName = "english_name"
    }
}
