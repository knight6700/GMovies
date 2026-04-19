//  MovieListFilterViewModel.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Combine
import Foundation
import Observation
import Utilities

@MainActor
@Observable
public final class MovieListFilterViewModel {
    public var searchQuery: String {
        didSet { searchQuerySubject.send(searchQuery) }
    }
    public var selectedGenreID: Int? {
        didSet { selectedGenreIDSubject.send(selectedGenreID) }
    }
    public private(set) var genreUIModels: [GenreUIModel] = []
    public private(set) var filteredUIModels: [MovieListItemUIModel] = []
    public var hasActiveSearch: Bool {
        !Self.normalizeSearchQuery(searchQuery).isEmpty
    }

    private let searchMoviesUseCase: SearchMoviesUseCase
    private let filterByGenreUseCase: FilterMoviesByGenreUseCase
    private let itemUIMapper: MovieListItemUIMapper
    @ObservationIgnored private let searchQuerySubject: CurrentValueSubject<String, Never>
    @ObservationIgnored private let selectedGenreIDSubject: CurrentValueSubject<Int?, Never>
    @ObservationIgnored private let moviesSubject: CurrentValueSubject<[Movie], Never>
    @ObservationIgnored private var cancellables: Set<AnyCancellable> = []

    public init(
        searchMoviesUseCase: SearchMoviesUseCase = SearchMoviesUseCase(),
        filterByGenreUseCase: FilterMoviesByGenreUseCase = FilterMoviesByGenreUseCase(),
        imageURLBuilder: any ImageURLBuilding = ImageURLBuilder(baseURL: ""),
        searchQuery: String = "",
        selectedGenreID: Int? = nil
    ) {
        self.searchQuerySubject = CurrentValueSubject(searchQuery)
        self.selectedGenreIDSubject = CurrentValueSubject(selectedGenreID)
        self.moviesSubject = CurrentValueSubject([])
        self.searchMoviesUseCase = searchMoviesUseCase
        self.filterByGenreUseCase = filterByGenreUseCase
        self.itemUIMapper = MovieListItemUIMapper(imageURLBuilder: imageURLBuilder)
        self.searchQuery = searchQuery
        self.selectedGenreID = selectedGenreID
        bindFilteringPipeline()
    }

    public func clearGenreSelection() {
        selectedGenreID = nil
    }

    public func toggleGenreSelection(id: Int) {
        selectedGenreID = selectedGenreID == id ? nil : id
    }

    public func updateMovies(_ movies: [Movie]) {
        moviesSubject.send(movies)
    }

    public func updateGenres(_ genres: [GenreUIModel]) {
        genreUIModels = genres
    }

    private func bindFilteringPipeline() {
        let normalizedSearchQuery = searchQuerySubject
            .map(Self.normalizeSearchQuery)
            .removeDuplicates()

        Publishers.CombineLatest3(
            moviesSubject,
            normalizedSearchQuery,
            selectedGenreIDSubject.removeDuplicates()
        )
        .sink { [weak self] movies, searchQuery, selectedGenreID in
            guard let self else { return }
            let searchedMovies = self.searchMoviesUseCase.execute(
                movies: movies,
                query: searchQuery
            )
            let filteredMovies = self.filterByGenreUseCase.execute(
                movies: searchedMovies,
                genreID: selectedGenreID
            )
            self.filteredUIModels = filteredMovies.map(self.itemUIMapper.map)
        }
        .store(in: &cancellables)
    }

    private static func normalizeSearchQuery(_ query: String) -> String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
