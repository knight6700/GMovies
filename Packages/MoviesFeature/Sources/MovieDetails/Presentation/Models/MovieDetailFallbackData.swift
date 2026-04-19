//  MovieDetailFallbackData.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

/// fallback from Movies List to show  data  until details api success
public struct MovieDetailFallbackData: Sendable {
    public let title: String
    public let posterPath: String?
    public let releaseYear: Int?
    public let overview: String?

    public init(
        title: String,
        posterPath: String?,
        releaseYear: Int?,
        overview: String?
    ) {
        self.title = title
        self.posterPath = posterPath
        self.releaseYear = releaseYear
        self.overview = overview
    }
}
