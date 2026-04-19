//  MovieDetail.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

public struct MovieDetail: Identifiable, Sendable {

    public let id: Int
    public let title: String
    public let posterPath: String?
    public let releaseDate: String?
    public let genres: [Genre]
    public let overview: String
    public let homepage: String?
    public let budget: Int
    public let revenue: Int
    public let status: String
    public let runtime: Int?
    public let spokenLanguages: [String]

    public init( // NOSONAR — domain entity maps 1:1 to API response fields
        id: Int,
        title: String,
        posterPath: String?,
        releaseDate: String?,
        genres: [Genre],
        overview: String,
        homepage: String?,
        budget: Int,
        revenue: Int,
        status: String,
        runtime: Int?,
        spokenLanguages: [String]
    ) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.genres = genres
        self.overview = overview
        self.homepage = homepage
        self.budget = budget
        self.revenue = revenue
        self.status = status
        self.runtime = runtime
        self.spokenLanguages = spokenLanguages
    }
}
