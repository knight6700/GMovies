//  MovieListFilterViewModelTests.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Testing
import Utilities
@testable import Movies

@Suite(.serialized)
struct MovieListFilterViewModelTests {

    @MainActor
    private func makeSUT(searchQuery: String = "") -> MovieListFilterViewModel {
        MovieListFilterViewModel(
            imageURLBuilder: ImageURLBuilder(baseURL: "https://image.tmdb.org/t/p/"),
            searchQuery: searchQuery
        )
    }

    @Test @MainActor
    func updateMovies_mapsToUIModels() {
        let sut = makeSUT()
        sut.updateMovies([
            MovieFixtures.makeMovie(id: 1, title: "Inception", posterPath: "/i.jpg", releaseYear: 2010),
            MovieFixtures.makeMovie(id: 2, title: "Interstellar", posterPath: "/inter.jpg", releaseYear: 2014)
        ])

        #expect(sut.filteredUIModels.map(\.title) == ["Inception", "Interstellar"])
    }

    @Test @MainActor
    func search_filtersMovies() {
        let sut = makeSUT()
        sut.updateMovies([
            MovieFixtures.makeMovie(id: 1, title: "Inception"),
            MovieFixtures.makeMovie(id: 2, title: "Interstellar"),
            MovieFixtures.makeMovie(id: 3, title: "The Prestige")
        ])

        sut.searchQuery = "inter"

        #expect(sut.filteredUIModels.map(\.title) == ["Interstellar"])
        #expect(sut.hasActiveSearch)
    }

    @Test @MainActor
    func genreToggle_selectsAndDeselects() {
        let sut = makeSUT()
        sut.updateMovies([
            MovieFixtures.makeMovie(id: 1, title: "Inception", genreIDs: [28]),
            MovieFixtures.makeMovie(id: 2, title: "Marriage Story", genreIDs: [18])
        ])

        sut.toggleGenreSelection(id: 28)
        #expect(sut.filteredUIModels.map(\.title) == ["Inception"])

        sut.toggleGenreSelection(id: 28)
        #expect(sut.filteredUIModels.count == 2)
    }

    @Test @MainActor
    func searchAndGenre_showsIntersection() {
        let sut = makeSUT(searchQuery: "story")
        sut.updateMovies([
            MovieFixtures.makeMovie(id: 1, title: "Toy Story", genreIDs: [16]),
            MovieFixtures.makeMovie(id: 2, title: "Marriage Story", genreIDs: [18]),
            MovieFixtures.makeMovie(id: 3, title: "West Side Story", genreIDs: [18])
        ])

        sut.toggleGenreSelection(id: 18)

        #expect(sut.filteredUIModels.map(\.title) == ["Marriage Story", "West Side Story"])
    }
}
