//  MovieDetailPreviewData.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

/// fallback to MoviesDetails from MoviesList
public struct MovieDetailPreviewData: Hashable, Sendable {
    public let id: Int
    public let title: String
    public let posterPath: String?
    public let releaseYear: Int?
    public let overview: String?

    public init(
        id: Int,
        title: String,
        posterPath: String?,
        releaseYear: Int?,
        overview: String?
    ) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.releaseYear = releaseYear
        self.overview = overview
    }
}
