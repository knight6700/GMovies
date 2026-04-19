//  MovieFixtures.swift
//  GMoviesTests
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.


@testable import Movies

enum MovieFixtures {

    static func makeMovie(
        id: Int = 1,
        title: String = "Inception",
        posterPath: String? = "/i.jpg",
        releaseYear: Int = 2010,
        genreIDs: [Int] = [28],
        overview: String = "Dreams.",
        voteAverage: Double = 8.8
    ) -> Movie {
        Movie(
            id: id,
            title: title,
            posterPath: posterPath,
            releaseYear: releaseYear,
            genreIDs: genreIDs,
            overview: overview,
            voteAverage: voteAverage
        )
    }

    static func makeMovies(range: ClosedRange<Int>) -> [Movie] {
        range.map { index in
            makeMovie(
                id: index,
                title: "Movie \(index)",
                posterPath: nil,
                releaseYear: 2024,
                genreIDs: [],
                overview: "",
                voteAverage: 7.0
            )
        }
    }
}
