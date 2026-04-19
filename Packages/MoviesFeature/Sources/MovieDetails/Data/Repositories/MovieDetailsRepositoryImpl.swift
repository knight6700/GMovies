//  MovieDetailsRepositoryImpl.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import Networking
import OSLog
import Persistence
import Utilities


public final class MovieDetailsRepositoryImpl: MovieDetailsRepository, Sendable {
    private let client: any HTTPClient
    private let local: any MovieDetailsLocalDataSource
    private let connectivity: any ConnectionStatus
    private let cacheMaxAge: TimeInterval
    private let now: @Sendable () -> Date

    public init(
        client: any HTTPClient,
        local: any MovieDetailsLocalDataSource,
        connectivity: any ConnectionStatus,
        cacheMaxAge: TimeInterval = 60 * 60 * 12,
        now: @escaping @Sendable () -> Date = { .now }
    ) {
        self.client = client
        self.local = local
        self.connectivity = connectivity
        self.cacheMaxAge = cacheMaxAge
        self.now = now
    }

    public func getMovieDetail(id: Int) async throws -> MovieDetail {
        try await resolveMovieDetail(id: id, strategy: .standard)
    }

    public func refreshMovieDetail(id: Int) async throws -> MovieDetail {
        try await resolveMovieDetail(id: id, strategy: .forceRefresh)
    }

    private func resolveMovieDetail(
        id: Int,
        strategy: CacheFetchStrategy
    ) async throws -> MovieDetail {
        try await CachePolicy.resolve(
            isConnected: await connectivity.isConnected,
            strategy: strategy,
            maxAge: cacheMaxAge,
            now: now(),
            offlineError: NetworkError.transport(URLError(.notConnectedToInternet)),
            snapshot: { [self] in await cachedDetailResource(id: id) },
            cachedValue: { [self] fallbackError in
                try await cachedDetail(id: id, fallbackError: fallbackError)
            },
            networkValue: { [self] in
                try await networkDetail(id: id)
            }
        )
    }

    private func networkDetail(id: Int) async throws -> MovieDetail {
        let dto: MovieDetailDTO = try await client.send(MovieDetailsRequest.detail(id: id))
        let detail = MovieDetailMapper.map(dto)
        do {
            try await local.saveMovieDetail(detail)
        } catch {
            Logger.movieDetailsRepo.error("save failed: \(error.localizedDescription, privacy: .public)")
        }
        return detail
    }

    private func cachedDetail(id: Int, fallbackError: Error) async throws -> MovieDetail {
        let cached = try await local.loadMovieDetail(id: id)
        guard let detail = cached.value else { throw fallbackError }
        return detail
    }

    private func cachedDetailResource(id: Int) async -> LocalSnapshot<MovieDetail>? {
        do {
            let cached = try await local.loadMovieDetail(id: id)
            guard let value = cached.value else { return nil }
            return LocalSnapshot(value: value, cachedAt: cached.cachedAt)
        } catch {
            return nil
        }
    }

}
