//  ImageURLBuilder.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation

public protocol ImageURLBuilding: Sendable {
    func url(for posterPath: String?, size: ImageURLBuilder.Size) -> URL?
}

public struct ImageURLBuilder: ImageURLBuilding, Sendable {

    public enum Size: String {
        case w185
        case w500
        case original
    }

    public let baseURL: String

    public init(baseURL: String) {
        self.baseURL = baseURL
    }

    /// Build a full image URL for the given poster path. Returns nil for empty paths.
    public func url(for posterPath: String?, size: Size = .w500) -> URL? {
        guard let path = posterPath, !path.isEmpty else { return nil }
        return URL(string: baseURL + size.rawValue + path)
    }
}
