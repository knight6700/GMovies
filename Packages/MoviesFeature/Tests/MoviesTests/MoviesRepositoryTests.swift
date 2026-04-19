//  MoviesRepositoryTests.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import Persistence
import Testing
import Networking
@testable import Movies

private let movie = Movie(
    id: 1, title: "M", posterPath: nil, releaseYear: 2024,
    genreIDs: [], overview: "", voteAverage: 7.0
)
private let genre = Genre(id: 1, name: "Action")

@Suite("MoviesRepository", .serialized)
struct MoviesRepositoryTests {

    private let token = MockURLProtocol.SerializerToken()
    private let fixedNow = Date(timeIntervalSinceReferenceDate: 123_456)

    private func makeClient(
        json: String,
        statusCode: Int = 200
    ) -> URLSessionHTTPClient {
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(fileURLWithPath: "/test"),
                statusCode: statusCode, httpVersion: nil, headerFields: nil
            )!
            return (response, Data(json.utf8))
        }
        return URLSessionHTTPClient(
            config: APIConfiguration(baseURL: "https://api.themoviedb.org/3", accessToken: "test"),
            session: .stubbed()
        )
    }

    private func makeFailingClient() -> URLSessionHTTPClient {
        MockURLProtocol.requestHandler = { _ in throw URLError(.timedOut) }
        return URLSessionHTTPClient(
            config: APIConfiguration(baseURL: "https://api.themoviedb.org/3", accessToken: "test"),
            session: .stubbed(), maxRetries: 0
        )
    }

    private let moviesJSON = #"{"page":1,"results":[{"id":1,"title":"M","poster_path":null,"release_date":"2024-01-01","genre_ids":[],"overview":"","vote_average":7.0}],"total_pages":1}"#
    private let genresJSON = #"{"genres":[{"id":28,"name":"Action"}]}"#

    // MARK: - Offline

    @Test
    func offline_returnsLocalMovies() async throws {
        let local = MockMoviesLocalDataSource()
        local.moviesResult = .success(LocalSnapshot(
            value: PaginatedResult(items: [movie], page: 1, totalPages: 1), cachedAt: .now
        ))
        let repo = MoviesRepositoryImpl(
            client: makeClient(json: ""), local: local,
            connectivity: MockConnectionMonitor(isConnected: false)
        )

        let output = try await repo.getPopularMovies(page: 1)
        #expect(output.items.count == 1)
    }

    @Test
    func offline_returnsLocalGenres() async throws {
        let local = MockMoviesLocalDataSource()
        local.genresResult = .success(LocalSnapshot(value: [genre], cachedAt: .now))
        let repo = MoviesRepositoryImpl(
            client: makeClient(json: ""), local: local,
            connectivity: MockConnectionMonitor(isConnected: false)
        )

        let output = try await repo.getGenres()
        #expect(output.count == 1)
    }

    // MARK: - Online

    @Test
    func online_savesMoviesToLocal() async throws {
        let local = MockMoviesLocalDataSource()
        let repo = MoviesRepositoryImpl(
            client: makeClient(json: moviesJSON), local: local,
            connectivity: MockConnectionMonitor(isConnected: true)
        )

        _ = try await repo.getPopularMovies(page: 1)
        #expect(local.savedMovies.count == 1)
    }

    @Test
    func online_staleCache_refreshesFromNetwork() async throws {
        let local = MockMoviesLocalDataSource()
        local.moviesResult = .success(LocalSnapshot(
            value: PaginatedResult(items: [movie], page: 1, totalPages: 1),
            cachedAt: fixedNow.addingTimeInterval(-3600)
        ))
        let networkMovie = Movie(id: 99, title: "Network", posterPath: nil, releaseYear: 2024,
                                 genreIDs: [], overview: "", voteAverage: 9.0)
        let networkJSON = #"{"page":1,"results":[{"id":99,"title":"Network","poster_path":null,"release_date":"2024-01-01","genre_ids":[],"overview":"","vote_average":9.0}],"total_pages":1}"#
        let repo = MoviesRepositoryImpl(
            client: makeClient(json: networkJSON),
            local: local, connectivity: MockConnectionMonitor(isConnected: true),
            now: { fixedNow }
        )

        let output = try await repo.getPopularMovies(page: 1)
        #expect(output.items == [networkMovie])
    }

    @Test
    func online_freshCache_skipsNetwork() async throws {
        let cachedMovie = Movie(id: 77, title: "Cached", posterPath: nil, releaseYear: 2024,
                                genreIDs: [], overview: "", voteAverage: 8.0)
        let local = MockMoviesLocalDataSource()
        local.moviesResult = .success(LocalSnapshot(
            value: PaginatedResult(items: [cachedMovie], page: 1, totalPages: 1),
            cachedAt: fixedNow.addingTimeInterval(-60)
        ))
        let repo = MoviesRepositoryImpl(
            client: makeClient(json: moviesJSON),
            local: local, connectivity: MockConnectionMonitor(isConnected: true),
            now: { fixedNow }
        )

        let output = try await repo.getPopularMovies(page: 1)
        #expect(output.items == [cachedMovie])
    }

    @Test
    func online_networkFails_fallsBackToCache() async throws {
        let local = MockMoviesLocalDataSource()
        local.moviesResult = .success(LocalSnapshot(
            value: PaginatedResult(items: [movie], page: 1, totalPages: 1), cachedAt: .now
        ))
        let repo = MoviesRepositoryImpl(
            client: makeFailingClient(), local: local,
            connectivity: MockConnectionMonitor(isConnected: true)
        )

        let output = try await repo.getPopularMovies(page: 1)
        #expect(output.items == [movie])
    }

    @Test
    func online_persistenceFails_stillReturnsNetworkData() async throws {
        let local = MockMoviesLocalDataSource()
        local.saveMoviesError = URLError(.cannotCreateFile)
        let repo = MoviesRepositoryImpl(
            client: makeClient(json: moviesJSON), local: local,
            connectivity: MockConnectionMonitor(isConnected: true)
        )

        let output = try await repo.getPopularMovies(page: 1)
        #expect(output.items == [movie])
    }
}
