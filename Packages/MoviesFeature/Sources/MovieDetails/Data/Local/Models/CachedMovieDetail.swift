//  CachedMovieDetail.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import SwiftData

@Model
final class CachedMovieDetail {

    @Attribute(.unique) var id: Int
    var title: String
    var posterPath: String?
    var releaseDate: String?
    var genreIDs: [Int]
    var genreNames: [String]
    var overview: String
    var homepage: String?
    var budget: Int
    var revenue: Int
    var status: String
    var runtime: Int?
    var spokenLanguages: [String]
    var cachedAt: Date

    init( // NOSONAR — SwiftData @Model requires memberwise init
        id: Int,
        title: String,
        posterPath: String?,
        releaseDate: String?,
        genreIDs: [Int],
        genreNames: [String],
        overview: String,
        homepage: String?,
        budget: Int,
        revenue: Int,
        status: String,
        runtime: Int?,
        spokenLanguages: [String],
        cachedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.genreIDs = genreIDs
        self.genreNames = genreNames
        self.overview = overview
        self.homepage = homepage
        self.budget = budget
        self.revenue = revenue
        self.status = status
        self.runtime = runtime
        self.spokenLanguages = spokenLanguages
        self.cachedAt = cachedAt
    }
}
