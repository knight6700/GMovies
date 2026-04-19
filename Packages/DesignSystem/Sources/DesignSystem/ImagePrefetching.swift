//  ImagePrefetching.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation

public protocol ImagePrefetching {
    func prefetch(urls: [URL])
    func cancelPrefetch(urls: [URL])
}
