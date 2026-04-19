//  CachedMoviesPage.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import SwiftData

@Model
final class CachedMoviesPage {

    @Attribute(.unique) var page: Int
    var movieIDs: [Int]
    var totalPages: Int
    var cachedAt: Date

    init(
        page: Int,
        movieIDs: [Int],
        totalPages: Int,
        cachedAt: Date = .now
    ) {
        self.page = page
        self.movieIDs = movieIDs
        self.totalPages = totalPages
        self.cachedAt = cachedAt
    }
}
