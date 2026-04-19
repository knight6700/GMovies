//  URLSessionHTTPClient.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import OSLog
import Utilities

public final class URLSessionHTTPClient: HTTPClient, Sendable {

    private let session: URLSession
    private let config: APIConfiguration
    private let decoder: JSONDecoder
    private let timeout: TimeInterval
    private let retryPolicy: RetryPolicy

    public convenience init(
        config: APIConfiguration,
        session: URLSession,
        maxRetries: Int = 2,
        timeout: TimeInterval = 20,
        baseRetryDelay: TimeInterval = 0.5
    ) {
        self.init(
            config: config,
            session: session,
            timeout: timeout,
            retryPolicy: RetryPolicy(
                maxAttempts: maxRetries,
                baseDelay: baseRetryDelay
            )
        )
    }

    init(
        config: APIConfiguration,
        session: URLSession,
        timeout: TimeInterval = 20,
        retryPolicy: RetryPolicy
    ) {
        self.config = config
        self.session = session
        self.decoder = JSONDecoder()
        self.timeout = timeout
        self.retryPolicy = retryPolicy
    }

    public func send<T: Decodable>(_ request: any Request) async throws(NetworkError) -> T {
        var lastError: NetworkError?

        for attempt in 0...retryPolicy.maxAttempts {
            do {
                return try await execute(request, attempt: attempt)
            } catch  {
                lastError = error
                guard retryPolicy.shouldRetry(error, attempt: attempt) else {
                    throw error
                }

                let delayMilliseconds = retryPolicy.delayMilliseconds(for: attempt)
                Logger.api.info(
                    "↻ retrying in \(delayMilliseconds)ms (attempt \(attempt + 1))"
                )
                try await retryPolicy.sleep(for: delayMilliseconds)
            }
        }

        throw lastError ?? .invalidResponse
    }

    private func execute<T: Decodable>(
        _ request: any Request,
        attempt: Int
    ) async throws(NetworkError) -> T {
        let urlRequest = try RequestBuilder.build(request, config: config, timeout: timeout)
        let path = urlRequest.url?.path ?? "?"

        Logger.api.info("→ \(path, privacy: .public) attempt=\(attempt + 1)")

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw mapError(error)
        }

        let http = try Response.validate(response)
        Logger.api.info("← \(path, privacy: .public) \(http.statusCode)")
        return try Response.decode(data, using: decoder)
    }

    private func mapError(_ error: Error) -> NetworkError {
        if let networkError = error as? NetworkError {
            return networkError
        }
        if let urlError = error as? URLError {
            return .transport(urlError)
        }
        if error is CancellationError {
            return .transport(URLError(.cancelled))
        }
        return .decoding(error.localizedDescription)
    }
}
