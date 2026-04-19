//  RetryPolicy.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation

public struct RetryPolicy: Sendable {

    public static let `default` = RetryPolicy()

    public let maxAttempts: Int
    public let baseDelay: TimeInterval

    private let nextJitterMultiplier: @Sendable () -> Double
    private let sleep: @Sendable (UInt64) async throws -> Void

    public init(
        maxAttempts: Int = 2,
        baseDelay: TimeInterval = 0.5,
        nextJitterMultiplier: @escaping @Sendable () -> Double = {
            Double.random(in: 0.8...1.2)
        },
        sleep: @escaping @Sendable (UInt64) async throws -> Void = {
            try await Task.sleep(nanoseconds: $0)
        }
    ) {
        self.maxAttempts = max(maxAttempts, 0)
        self.baseDelay = max(baseDelay, 0)
        self.nextJitterMultiplier = nextJitterMultiplier
        self.sleep = sleep
    }

    func shouldRetry(_ error: NetworkError, attempt: Int) -> Bool {
        error.isRetryable && attempt < maxAttempts
    }

    func delayMilliseconds(for attempt: Int) -> Int {
        let baseMilliseconds = max(
            Int((baseDelay * pow(2, Double(attempt)) * 1_000).rounded()),
            1
        )
        let jitterMultiplier = max(nextJitterMultiplier(), 0)
        return max(
            Int((Double(baseMilliseconds) * jitterMultiplier).rounded()),
            1
        )
    }

    func sleep(for delayMilliseconds: Int) async throws(NetworkError) {
        do {
            try await sleep(UInt64(delayMilliseconds) * 1_000_000)
        } catch is CancellationError {
            throw .transport(URLError(.cancelled))
        } catch {
            throw .transport(URLError(.unknown))
        }
    }
}
