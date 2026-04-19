//  MovieListItemUIModel.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation

public struct MovieListItemUIModel: Identifiable, Hashable {
    public let id: Int
    public let title: String
    public let posterURL: URL?
    public let rating: Double
    public let year: String?

    public var yearInt: Int? { year.flatMap { Int($0) } }

    public init(
        id: Int,
        title: String,
        posterURL: URL?,
        rating: Double,
        year: String?
    ) {
        self.id = id
        self.title = title
        self.posterURL = posterURL
        self.rating = rating
        self.year = year
    }
}
