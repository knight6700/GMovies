//  Logger+DesignSystem.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import OSLog
import Utilities

extension Logger {
    static let imageCache = Logger.app("ImageCache")
    static let imageLoader = Logger.app("ImageLoader")
    static let imagePrefetcher = Logger.app("ImagePrefetcher")
}
