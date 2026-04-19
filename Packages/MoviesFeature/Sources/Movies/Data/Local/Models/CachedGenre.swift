//  CachedGenre.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import SwiftData
import Foundation

@Model
final class CachedGenre {

    @Attribute(.unique) var id: Int
    var name: String
    var cachedAt: Date

    init(
        id: Int,
        name: String,
        cachedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.cachedAt = cachedAt
    }
}
