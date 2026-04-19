import Foundation
import Testing
import os
import Networking
import Persistence
@testable import MovieDetails

private let detail = MovieDetail(
    id: 1,
    title: "M",
    posterPath: nil,
    releaseDate: nil,
    genres: [],
    overview: "",
    homepage: nil,
    budget: 0,
    revenue: 0,
    status: "Released",
    runtime: nil,
    spokenLanguages: []
)

@Suite(.serialized)
struct MovieDetailsRepositoryTests {

    private let token = MockURLProtocol.SerializerToken()
    private let fixedNow = Date(timeIntervalSinceReferenceDate: 123_456)

    private let detailJSON = Data("""
    {"id":1,"title":"M","poster_path":null,"release_date":null,"genres":[],"overview":"","homepage":null,"budget":0,"revenue":0,"status":"Released","runtime":null,"spoken_languages":[]}
    """.utf8)

    private func makeAPIClient(
        jsonData: Data,
        statusCode: Int = 200,
        onRequest: (@Sendable () -> Void)? = nil
    ) -> URLSessionHTTPClient {
        MockURLProtocol.requestHandler = { _ in
            onRequest?()
            let url = URL(fileURLWithPath: "/test")
            guard let response = HTTPURLResponse(
                url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil
            ) else {
                struct InvalidResponse: Error {}
                throw InvalidResponse()
            }
            return (response, jsonData)
        }
        return URLSessionHTTPClient(
            config: APIConfiguration(
                baseURL: "https://api.themoviedb.org/3",
                accessToken: "test"
            ),
            session: .stubbed()
        )
    }

    @Test
    func offlineReturnsCachedDetail() async throws {
        let local = MockMovieDetailsLocalDataSource()
        local.detailResult = LocalSnapshot(value: detail, cachedAt: .now)
        let repo = MovieDetailsRepositoryImpl(
            client: makeAPIClient(jsonData: Data()),
            local: local,
            connectivity: MockConnectionMonitor(isConnected: false)
        )
        let output = try await repo.getMovieDetail(id: 1)
        #expect(output.id == 1)
    }

    @Test
    func onlineReturnsNetworkDetail() async throws {
        let local = MockMovieDetailsLocalDataSource()
        let repo = MovieDetailsRepositoryImpl(
            client: makeAPIClient(jsonData: detailJSON),
            local: local,
            connectivity: MockConnectionMonitor(isConnected: true)
        )
        let output = try await repo.getMovieDetail(id: 1)
        #expect(output.title == "M")
    }

    @Test
    func staleCacheRefreshesFromNetwork() async throws {
        let networkCalled = OSAllocatedUnfairLock(initialState: false)
        let cachedDetail = MovieDetail(
            id: 1, title: "Cached", posterPath: nil, releaseDate: nil,
            genres: [], overview: "", homepage: nil, budget: 0, revenue: 0,
            status: "Released", runtime: nil, spokenLanguages: []
        )
        let local = MockMovieDetailsLocalDataSource()
        local.detailResult = LocalSnapshot(
            value: cachedDetail,
            cachedAt: fixedNow.addingTimeInterval(-50_000)
        )
        let repo = MovieDetailsRepositoryImpl(
            client: makeAPIClient(jsonData: detailJSON, onRequest: {
                networkCalled.withLock { $0 = true }
            }),
            local: local,
            connectivity: MockConnectionMonitor(isConnected: true),
            now: { fixedNow }
        )

        let output = try await repo.getMovieDetail(id: 1)

        #expect(output.title == "M")
        #expect(networkCalled.withLock { $0 })
    }

    @Test
    func freshCacheSkipsNetwork() async throws {
        let networkCalled = OSAllocatedUnfairLock(initialState: false)
        let cachedDetail = MovieDetail(
            id: 1, title: "Cached", posterPath: nil, releaseDate: nil,
            genres: [], overview: "", homepage: nil, budget: 0, revenue: 0,
            status: "Released", runtime: nil, spokenLanguages: []
        )
        let local = MockMovieDetailsLocalDataSource()
        local.detailResult = LocalSnapshot(
            value: cachedDetail,
            cachedAt: fixedNow.addingTimeInterval(-60)
        )
        let repo = MovieDetailsRepositoryImpl(
            client: makeAPIClient(jsonData: Data(), onRequest: {
                networkCalled.withLock { $0 = true }
            }),
            local: local,
            connectivity: MockConnectionMonitor(isConnected: true),
            now: { fixedNow }
        )

        let output = try await repo.getMovieDetail(id: 1)

        #expect(output.title == "Cached")
        #expect(!networkCalled.withLock { $0 })
    }

    @Test
    func networkFailureFallsBackToCache() async throws {
        let local = MockMovieDetailsLocalDataSource()
        local.detailResult = LocalSnapshot(value: detail, cachedAt: .now)
        MockURLProtocol.requestHandler = { _ in throw URLError(.timedOut) }
        let repo = MovieDetailsRepositoryImpl(
            client: URLSessionHTTPClient(
                config: APIConfiguration(baseURL: "https://api.themoviedb.org/3", accessToken: "test"),
                session: .stubbed(),
                maxRetries: 0
            ),
            local: local,
            connectivity: MockConnectionMonitor(isConnected: true)
        )

        let output = try await repo.getMovieDetail(id: 1)
        #expect(output.id == detail.id)
    }
}
