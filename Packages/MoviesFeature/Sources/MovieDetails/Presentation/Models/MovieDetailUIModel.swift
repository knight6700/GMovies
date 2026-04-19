//  MovieDetailUIModel.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation

public struct MovieDetailUIModel: Equatable {
    public let posterPath: String?
    public let thumbnailPosterURL: URL?
    public let heroPosterURL: URL?
    public let title: String
    public let titleWithYear: String
    public let genres: String?
    public let overview: String?
    public let homepageURL: URL?
    public let languages: String?
    public let status: String?
    public let runtime: String?
    public let budget: String?
    public let revenue: String?
    public let releaseDate: String?
    public let showOfflineBanner: Bool

    public init( // NOSONAR — UI model maps 1:1 to detail screen fields
        posterPath: String?,
        thumbnailPosterURL: URL? = nil,
        heroPosterURL: URL? = nil,
        title: String,
        titleWithYear: String,
        genres: String?,
        overview: String?,
        homepageURL: URL?,
        languages: String?,
        status: String?,
        runtime: String?,
        budget: String?,
        revenue: String?,
        releaseDate: String?,
        showOfflineBanner: Bool
    ) {
        self.posterPath = posterPath
        self.thumbnailPosterURL = thumbnailPosterURL
        self.heroPosterURL = heroPosterURL
        self.title = title
        self.titleWithYear = titleWithYear
        self.genres = genres
        self.overview = overview
        self.homepageURL = homepageURL
        self.languages = languages
        self.status = status
        self.runtime = runtime
        self.budget = budget
        self.revenue = revenue
        self.releaseDate = releaseDate
        self.showOfflineBanner = showOfflineBanner
    }
}
