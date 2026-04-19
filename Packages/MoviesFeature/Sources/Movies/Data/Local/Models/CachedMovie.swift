//  CachedMovie.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import SwiftData

@Model
final class CachedMovie {

    @Attribute(.unique) var id: Int
    var title: String
    var posterPath: String?
    var releaseYear: Int?
    var genreIDs: [Int]
    var overview: String
    var voteAverage: Double
    var updatedAt: Date

    init( // NOSONAR — SwiftData @Model requires memberwise init
        id: Int,
        title: String,
        posterPath: String?,
        releaseYear: Int?,
        genreIDs: [Int],
        overview: String,
        voteAverage: Double,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.releaseYear = releaseYear
        self.genreIDs = genreIDs
        self.overview = overview
        self.voteAverage = voteAverage
        self.updatedAt = updatedAt
    }
}
