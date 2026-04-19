//
//  DiscoverMoviesQuery.swift
//  MoviesFeature
//
//  Created by MahmoudFares on 19/04/2026.
//


public struct DiscoverMoviesQuery: Encodable, Sendable {
    public let page: Int
    public let includeAdult: Bool
    public let sortBy: SortBy

    public init(page: Int, includeAdult: Bool = false, sortBy: SortBy = .popularityDescending) {
        self.page = page
        self.includeAdult = includeAdult
        self.sortBy = sortBy
    }

    public enum SortBy: String, Encodable, Sendable {
        case popularityAscending = "popularity.asc"
        case popularityDescending = "popularity.desc"
    }
}
