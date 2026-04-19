//  ImageURLBuilderTests.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Testing
@testable import Utilities

@Suite("ImageURLBuilder")
struct ImageURLBuilderTests {

    private let builder = ImageURLBuilder(baseURL: "https://image.tmdb.org/t/p/")

    @Test
    func buildsURLWithSize() {
        let url = builder.url(for: "/poster.jpg", size: .w500)
        #expect(url?.absoluteString == "https://image.tmdb.org/t/p/w500/poster.jpg")
    }

    @Test
    func buildsURLWithDifferentSize() {
        let url = builder.url(for: "/poster.jpg", size: .w185)
        #expect(url?.absoluteString == "https://image.tmdb.org/t/p/w185/poster.jpg")
    }

    @Test
    func returnsNilForNilPath() {
        #expect(builder.url(for: nil, size: .w500) == nil)
    }

    @Test
    func returnsNilForEmptyPath() {
        #expect(builder.url(for: "", size: .w500) == nil)
    }
}
