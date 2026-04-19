//  MovieDetailsRequest.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import Networking

public enum MovieDetailsRequest: Request {
    case detail(id: Int)

    public var path: String {
        switch self {
        case .detail(let id):
            return "movie/\(id)"
        }
    }

    public var query: (any Encodable & Sendable)? {
        nil
    }
}
