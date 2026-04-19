//  Movie.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

public struct Movie: Identifiable, Hashable, Sendable {

    public let id: Int
    public let title: String
    public let posterPath: String?
    public let releaseYear: Int?
    public let genreIDs: [Int]
    public let overview: String
    public let voteAverage: Double

    public init(
        id: Int,
        title: String,
        posterPath: String?,
        releaseYear: Int?,
        genreIDs: [Int],
        overview: String,
        voteAverage: Double
    ) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.releaseYear = releaseYear
        self.genreIDs = genreIDs
        self.overview = overview
        self.voteAverage = voteAverage
    }
}
