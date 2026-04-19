//  PosterPrefetcher.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import DesignSystem

public protocol PosterPrefetching {
    func execute(posterURLs: [URL?], currentIndex: Int, windowSize: Int)
}

extension PosterPrefetching {
    public func execute(posterURLs: [URL?], currentIndex: Int) {
        execute(posterURLs: posterURLs, currentIndex: currentIndex, windowSize: 6)
    }
}

public final class PosterPrefetcher: PosterPrefetching {
    private let prefetcher: any ImagePrefetching

    public init(prefetcher: any ImagePrefetching) {
        self.prefetcher = prefetcher
    }

    public func execute(posterURLs: [URL?], currentIndex: Int, windowSize: Int = 6) {
        let start = currentIndex + 1
        let end = min(start + windowSize, posterURLs.count)
        guard start < end else { return }
        let urls = posterURLs[start..<end].compactMap { $0 }
        prefetcher.prefetch(urls: urls)
    }
}
