//  MoviesRequest.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import Networking

public enum MoviesRequest: Request {
    case discover(DiscoverMoviesQuery)
    case genres

    public static func popular(page: Int) -> Self {
        .discover(DiscoverMoviesQuery(page: page))
    }

    public var path: String {
        switch self {
        case .discover: "discover/movie"
        case .genres: "genre/movie/list"
        }
    }

    public var query: (any Encodable & Sendable)? {
        switch self {
        case .discover(let query): query
        case .genres: nil
        }
    }
}
