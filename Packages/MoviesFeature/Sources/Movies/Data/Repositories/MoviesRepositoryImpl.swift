//  MoviesRepositoryImpl.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import Networking
import OSLog
import Persistence
import Utilities


public final class MoviesRepositoryImpl: PopularMoviesRepository, GenreRepository, Sendable {
    private let client: any HTTPClient
    private let local: any MoviesLocalDataSource
    private let connectivity: any ConnectionStatus
    private let moviesCacheMaxAge: TimeInterval
    private let genresCacheMaxAge: TimeInterval
    private let now: @Sendable () -> Date

    public init(
        client: any HTTPClient,
        local: any MoviesLocalDataSource,
        connectivity: any ConnectionStatus,
        moviesCacheMaxAge: TimeInterval = 60 * 30,
        genresCacheMaxAge: TimeInterval = 60 * 60 * 24,
        now: @escaping @Sendable () -> Date = { .now }
    ) {
        self.client = client
        self.local = local
        self.connectivity = connectivity
        self.moviesCacheMaxAge = moviesCacheMaxAge
        self.genresCacheMaxAge = genresCacheMaxAge
        self.now = now
    }

    public func getPopularMovies(page: Int) async throws -> PaginatedResult<Movie> {
        try await resolvePopularMovies(page: page, strategy: .standard)
    }

    public func refreshPopularMovies(page: Int) async throws -> PaginatedResult<Movie> {
        try await resolvePopularMovies(page: page, strategy: .forceRefresh)
    }

    public func getGenres() async throws -> [Genre] {
        try await resolveGenres(strategy: .standard)
    }

    public func refreshGenres() async throws -> [Genre] {
        try await resolveGenres(strategy: .forceRefresh)
    }

    private func resolvePopularMovies(
        page: Int,
        strategy: CacheFetchStrategy
    ) async throws -> PaginatedResult<Movie> {
        try await CachePolicy.resolve(
            isConnected: await connectivity.isConnected,
            strategy: strategy,
            maxAge: moviesCacheMaxAge,
            now: now(),
            offlineError: NetworkError.transport(URLError(.notConnectedToInternet)),
            snapshot: { [self] in await cachedMoviesResource(page: page) },
            cachedValue: { [self] fallbackError in
                try await cachedMovies(page: page, fallbackError: fallbackError)
            },
            networkValue: { [self] in
                try await networkMovies(page: page)
            }
        )
    }

    private func resolveGenres(strategy: CacheFetchStrategy) async throws -> [Genre] {
        try await CachePolicy.resolve(
            isConnected: await connectivity.isConnected,
            strategy: strategy,
            maxAge: genresCacheMaxAge,
            now: now(),
            offlineError: NetworkError.transport(URLError(.notConnectedToInternet)),
            snapshot: { [self] in await cachedGenresResource() },
            cachedValue: { [self] fallbackError in
                try await cachedGenres(fallbackError: fallbackError)
            },
            networkValue: { [self] in
                try await networkGenres()
            }
        )
    }

    private func networkMovies(page: Int) async throws -> PaginatedResult<Movie> {
        let dto: DiscoverMoviesResponseDTO = try await client.send(MoviesRequest.popular(page: page))
        let paginated = DiscoverMoviesResponseMapper.map(dto)
        do {
            try await local.saveMovies(
                paginated.items,
                page: paginated.page,
                totalPages: paginated.totalPages
            )
        } catch {
            Logger.moviesRepo.error("save failed: \(error.localizedDescription, privacy: .public)")
        }
        return paginated
    }

    private func networkGenres() async throws -> [Genre] {
        let dto: GenresResponseDTO = try await client.send(MoviesRequest.genres)
        let genres = GenresResponseMapper.map(dto)
        do {
            try await local.saveGenres(genres)
        } catch {
            Logger.moviesRepo.error("save failed: \(error.localizedDescription, privacy: .public)")
        }
        return genres
    }

    private func cachedMovies(page: Int, fallbackError: Error) async throws -> PaginatedResult<Movie> {
        let cached = try await local.loadMovies(page: page)
        guard !cached.value.items.isEmpty else { throw fallbackError }
        return cached.value
    }

    private func cachedMoviesResource(page: Int) async -> LocalSnapshot<PaginatedResult<Movie>>? {
        do {
            let cached = try await local.loadMovies(page: page)
            return cached.value.items.isEmpty ? nil : cached
        } catch {
            return nil
        }
    }

    private func cachedGenres(fallbackError: Error) async throws -> [Genre] {
        let cached = try await local.loadGenres()
        guard !cached.value.isEmpty else { throw fallbackError }
        return cached.value
    }

    private func cachedGenresResource() async -> LocalSnapshot<[Genre]>? {
        do {
            let cached = try await local.loadGenres()
            return cached.value.isEmpty ? nil : cached
        } catch {
            return nil
        }
    }

}
