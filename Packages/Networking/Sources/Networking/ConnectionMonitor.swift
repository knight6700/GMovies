//  ConnectionMonitor.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import Network
import OSLog
import Utilities


public protocol PathMonitoring: Sendable {
    func start(onChange: @escaping @Sendable (Bool) -> Void)
    func cancel()
}

public final class SystemPathMonitor: PathMonitoring {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.gmovies.connectivity")

    public init() {}

    public func start(onChange: @escaping @Sendable (Bool) -> Void) {
        monitor.pathUpdateHandler = { path in
            let connected = path.status == .satisfied && !path.availableInterfaces.isEmpty
            Logger.connectivity.debug("NWPath connected=\(connected)")
            onChange(connected)
        }
        monitor.start(queue: queue)
    }

    public func cancel() {
        monitor.cancel()
    }
}

public actor ConnectionMonitor: ConnectionObserving {

    private let pathMonitor: any PathMonitoring
    private var connectionState: Bool?
    private var continuation: AsyncStream<Bool>.Continuation?
    private var statusWaiters: [CheckedContinuation<Bool, Never>] = []

    public var isConnected: Bool {
        get async {
            if let connectionState {
                return connectionState
            }
            return await withCheckedContinuation { continuation in
                statusWaiters.append(continuation)
            }
        }
    }

    public init(pathMonitor: any PathMonitoring = SystemPathMonitor()) {
        self.pathMonitor = pathMonitor
        pathMonitor.start { [weak self] connected in
            guard let self else { return }
            Task {
                await self.handleChange(connected)
            }
        }
    }

    public func updates() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            if let connectionState {
                continuation.yield(connectionState)
            }
            self.continuation = continuation
            continuation.onTermination = { [weak self] _ in
                guard let self else { return }
                Task {
                    await self.clearContinuation()
                }
            }
        }
    }

    private func handleChange(_ connected: Bool) {
        let previousState = connectionState
        connectionState = connected

        if !statusWaiters.isEmpty {
            let waiters = statusWaiters
            statusWaiters.removeAll()
            for waiter in waiters {
                waiter.resume(returning: connected)
            }
        }

        guard previousState != connected else { return }
        continuation?.yield(connected)
    }

    private func clearContinuation() {
        continuation = nil
    }

    deinit {
        pathMonitor.cancel()
    }
}
