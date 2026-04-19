//  MovieDetailsDIContainer.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Networking
import OSLog
import SwiftData
import Utilities


@MainActor
public final class MovieDetailsDIContainer {

    private typealias LocalDataSourceFactory = @MainActor () throws -> any MovieDetailsLocalDataSource
    private let apiClient: any HTTPClient
    private let connectivity: any ConnectionStatus
    private let imageURLBuilder: any ImageURLBuilding
    private let autoLoadOnAppear: Bool
    private let localDataSourceFactory: LocalDataSourceFactory?

    public init(
        apiClient: any HTTPClient,
        connectivity: any ConnectionStatus,
        imageURLBuilder: any ImageURLBuilding,
        autoLoadOnAppear: Bool = true,
        localDataSourceFactory: (@MainActor () throws -> any MovieDetailsLocalDataSource)? = nil
    ) {
        self.apiClient = apiClient
        self.connectivity = connectivity
        self.imageURLBuilder = imageURLBuilder
        self.autoLoadOnAppear = autoLoadOnAppear
        self.localDataSourceFactory = localDataSourceFactory
    }

    private lazy var localDataSource: any MovieDetailsLocalDataSource = {
        do {
            return try makeLocalDataSource()
        } catch {
            Logger.movieDetailsDI.error("MovieDetails SwiftData init failed: \(String(describing: error), privacy: .public)")
            return InMemoryMovieDetailsLocalDataSource()
        }
    }()

    private lazy var repository: any MovieDetailsRepository = MovieDetailsRepositoryImpl(
        client: apiClient,
        local: localDataSource,
        connectivity: connectivity
    )

    public func makeMovieDetailScreen(
        movieID: Int,
        fallbackData: MovieDetailFallbackData? = nil
    ) -> MovieDetailScreen {
        MovieDetailScreen(
            viewModel: makeViewModel(
                movieID: movieID,
                fallbackData: fallbackData
            ),
            autoLoadOnAppear: autoLoadOnAppear
        )
    }

    private func makeViewModel(
        movieID: Int,
        fallbackData: MovieDetailFallbackData?
    ) -> MovieDetailViewModel {
        MovieDetailViewModel(
            movieID: movieID,
            repository: repository,
            fallbackData: fallbackData,
            imageURLBuilder: imageURLBuilder
        )
    }

    private func makeLocalDataSource() throws -> any MovieDetailsLocalDataSource {
        if let localDataSourceFactory {
            return try localDataSourceFactory()
        }

        let container = try SwiftDataMovieDetailsLocalDataSource.makeContainer()
        return SwiftDataMovieDetailsLocalDataSource(container: container)
    }
}
