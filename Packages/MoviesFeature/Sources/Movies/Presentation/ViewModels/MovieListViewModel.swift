//  MovieListViewModel.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import Networking
import Utilities
import OSLog

@MainActor
@Observable
public final class MovieListViewModel {

    public var viewState: ViewState = .idle
    public var isOffline: Bool = false

    public var filteredUIModels: [MovieListItemUIModel] { filterViewModel.filteredUIModels }
    public var isLoadingMore: Bool { canPaginate ? pagination.isLoadingMore : false }
    public var pagingError: String? { canPaginate ? pagination.pagingError : nil }
    public let filterViewModel: MovieListFilterViewModel

    let pagination: PaginationController<Movie>
    private let moviesRepository: any PopularMoviesRepository
    private let genreRepository: any GenreRepository
    private let posterPrefetcher: any PosterPrefetching
    private var hasAttemptedInitialLoad = false
    private var wasOffline = false
    private var isRefreshing = false
    private var connectivityTask: Task<Void, Never>?

    private var canPaginate: Bool { !filterViewModel.hasActiveSearch }

    public init(
        pagination: PaginationController<Movie>,
        moviesRepository: any PopularMoviesRepository,
        genreRepository: any GenreRepository,
        posterPrefetcher: any PosterPrefetching,
        filterViewModel: MovieListFilterViewModel,
        connectivity: any ConnectionObserving
    ) {
        self.pagination = pagination
        self.moviesRepository = moviesRepository
        self.genreRepository = genreRepository
        self.posterPrefetcher = posterPrefetcher
        self.filterViewModel = filterViewModel
        bindConnectivity(connectivity)
    }

    public func loadIfNeeded() async {
        guard !hasAttemptedInitialLoad else { return }
        await loadInitial(force: true)
    }

    public func loadInitial(force: Bool = false) async {
        if force {
            guard viewState != .loading else { return }
        } else {
            switch viewState {
            case .idle, .error: break
            case .loading, .loaded, .empty: return
            }
        }
        hasAttemptedInitialLoad = true
        Logger.movieList.info("loadInitial → loading")
        viewState = .loading
        await fetchMovies(isRefresh: false)
    }

    public func refresh() async {
        guard viewState != .loading, !isRefreshing else { return }
        Logger.movieList.info("refresh → started")
        isRefreshing = true
        defer { isRefreshing = false }
        await fetchMovies(isRefresh: true)
    }

    public func loadNextPageIfNeeded(currentItemID: Int) async {
        guard canPaginate else { return }
        await pagination.loadNextPageIfNeeded(after: currentItemID)
        filterViewModel.updateMovies(pagination.items)
    }

    public func retryNextPage() async {
        guard canPaginate else { return }
        await pagination.retryNextPage()
        filterViewModel.updateMovies(pagination.items)
    }

    public func prefetchImages(after itemID: Int) {
        guard let index = filteredUIModels.firstIndex(where: { $0.id == itemID }) else { return }
        posterPrefetcher.execute(
            posterURLs: filteredUIModels.map(\.posterURL),
            currentIndex: index
        )
    }

    public func preview(for movieID: Int) -> MovieDetailPreviewData? {
        guard let movie = pagination.items.first(where: { $0.id == movieID }) else { return nil }
        return MovieDetailPreviewData(
            id: movie.id,
            title: movie.title,
            posterPath: movie.posterPath,
            releaseYear: movie.releaseYear,
            overview: movie.overview.isEmpty ? nil : movie.overview
        )
    }

    private func bindConnectivity(_ connectivity: any ConnectionObserving) {
        connectivityTask = Task { [weak self] in
            let updates = await connectivity.updates()
            for await isConnected in updates {
                guard let self else { return }
                self.handleConnectivityChange(isConnected)
            }
        }
    }

    private func handleConnectivityChange(_ isConnected: Bool) {
        isOffline = !isConnected
        if !isConnected {
            wasOffline = true
            return
        }
        guard wasOffline, hasAttemptedInitialLoad else { return }
        wasOffline = false
        switch viewState {
        case .loaded, .empty:
            enqueueRefresh()
        case .idle, .error:
            Task { @MainActor [weak self] in
                await self?.loadInitial(force: true)
            }
        case .loading:
            break
        }
    }

    private func enqueueRefresh() {
        guard viewState != .loading, !isRefreshing else { return }
        Logger.movieList.info("connectivity restored → refreshing")
        isRefreshing = true
        Task { @MainActor [weak self] in
            guard let self else { return }
            defer { self.isRefreshing = false }
            await self.fetchMovies(isRefresh: true)
        }
    }

    private func fetchMovies(isRefresh: Bool) async {
        let previousState = viewState

        do {
            async let paginated = isRefresh
                ? moviesRepository.refreshPopularMovies(page: 1)
                : moviesRepository.getPopularMovies(page: 1)
            async let genres = isRefresh
                ? genreRepository.refreshGenres()
                : genreRepository.getGenres()
            let (moviesPage, genresValue) = try await (paginated, genres)
            try Task.checkCancellation()

            let movies = moviesPage.items.uniquedByID()
            pagination.reset(items: movies, totalPages: moviesPage.totalPages)
            filterViewModel.updateMovies(movies)
            filterViewModel.updateGenres(genresValue.map(GenreUIMapper.map))
            viewState = movies.isEmpty ? .empty : .loaded
        } catch is CancellationError {
            Logger.movieList.info("\(isRefresh ? "refresh" : "loadInitial") cancelled")
            if !isRefresh {
                hasAttemptedInitialLoad = false
                viewState = .idle
            }
        } catch {
            Logger.movieList.error("\(isRefresh ? "refresh" : "loadInitial") failed: \(error.localizedDescription, privacy: .public)")
            if isRefresh, case .loaded = previousState {
                viewState = previousState
            } else if isRefresh, case .empty = previousState {
                viewState = previousState
            } else {
                viewState = .error(error.localizedDescription)
            }
        }
    }

}
