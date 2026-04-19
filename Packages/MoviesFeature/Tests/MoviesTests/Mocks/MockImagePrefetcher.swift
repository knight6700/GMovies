//  MockImagePrefetcher.swift
//  GMoviesTests
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import DesignSystem

final class MockImagePrefetcher: ImagePrefetching {
    var prefetchedURLs: [[URL]] = []
    var cancelledURLs: [[URL]] = []

    func prefetch(urls: [URL]) { prefetchedURLs.append(urls) }
    func cancelPrefetch(urls: [URL]) { cancelledURLs.append(urls) }
}
