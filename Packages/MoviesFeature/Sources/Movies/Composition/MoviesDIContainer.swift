//  MoviesDIContainer.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Networking
import OSLog
import DesignSystem
import SwiftData
import Utilities


@MainActor
public final class MoviesDIContainer {

    private typealias LocalDataSourceFactory = @MainActor () throws -> any MoviesLocalDataSource
    private let apiClient: any HTTPClient
    private let connectivity: any ConnectionObserving
    private let imagePrefetcher: any ImagePrefetching
    private let imageURLBuilder: any ImageURLBuilding
    private let autoLoadOnAppear: Bool
    private let localDataSourceFactory: LocalDataSourceFactory?

    public init(
        apiClient: any HTTPClient,
        connectivity: any ConnectionObserving,
        imagePrefetcher: any ImagePrefetching,
        imageURLBuilder: any ImageURLBuilding,
        autoLoadOnAppear: Bool = true,
        localDataSourceFactory: (@MainActor () throws -> any MoviesLocalDataSource)? = nil
    ) {
        self.apiClient = apiClient
        self.connectivity = connectivity
        self.imagePrefetcher = imagePrefetcher
        self.imageURLBuilder = imageURLBuilder
        self.autoLoadOnAppear = autoLoadOnAppear
        self.localDataSourceFactory = localDataSourceFactory
    }

    // MARK: - Data

    private lazy var localDataSource: any MoviesLocalDataSource = {
        do {
            return try makeLocalDataSource()
        } catch {
            Logger.moviesDI.error("Movies SwiftData init failed: \(String(describing: error), privacy: .public)")
            return InMemoryMoviesLocalDataSource()
        }
    }()

    private lazy var repository = MoviesRepositoryImpl(
        client: apiClient,
        local: localDataSource,
        connectivity: connectivity
    )

    // MARK: - Use Cases

    private lazy var posterPrefetcher = PosterPrefetcher(prefetcher: imagePrefetcher)

    // MARK: - Pagination

    private func makePaginationController() -> PaginationController<Movie> {
        PaginationController { page in
            try await self.repository.getPopularMovies(page: page)
        }
    }

    // MARK: - View

    public func makeMovieListScreen(router: any MovieListRouting) -> MovieListScreen {
        MovieListScreen(
            viewModel: self.makeViewModel(),
            router: router,
            autoLoadOnAppear: autoLoadOnAppear
        )
    }

    private func makeViewModel() -> MovieListViewModel {
        MovieListViewModel(
            pagination: makePaginationController(),
            moviesRepository: repository,
            genreRepository: repository,
            posterPrefetcher: posterPrefetcher,
            filterViewModel: makeFilterViewModel(),
            connectivity: connectivity
        )
    }
}

private extension MoviesDIContainer {
    func makeLocalDataSource() throws -> any MoviesLocalDataSource {
        if let localDataSourceFactory {
            return try localDataSourceFactory()
        }

        let container = try SwiftDataMoviesLocalDataSource.makeContainer()
        return SwiftDataMoviesLocalDataSource(container: container)
    }

    func makeFilterViewModel() -> MovieListFilterViewModel {
        MovieListFilterViewModel(
            searchMoviesUseCase: SearchMoviesUseCase(),
            filterByGenreUseCase: FilterMoviesByGenreUseCase(),
            imageURLBuilder: imageURLBuilder
        )
    }
}
