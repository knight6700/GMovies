//  AppLogger.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import OSLog

public extension Logger {
    static func app(_ category: String) -> Logger {
        Logger(subsystem: "com.gmovies", category: category)
    }
}
