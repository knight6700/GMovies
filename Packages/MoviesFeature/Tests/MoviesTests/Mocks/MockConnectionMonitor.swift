//  MockConnectionMonitor.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import Networking

actor MockConnectionMonitor: ConnectionObserving {

    private var continuation: AsyncStream<Bool>.Continuation?
    private var _isConnected: Bool

    var isConnected: Bool { _isConnected }

    init(isConnected: Bool = true) {
        self._isConnected = isConnected
    }

    func setConnected(_ value: Bool) {
        guard _isConnected != value else { return }
        _isConnected = value
        continuation?.yield(value)
    }

    func updates() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            continuation.yield(_isConnected)
            self.continuation = continuation
            continuation.onTermination = { [weak self] _ in
                guard let self else { return }
                Task { await self.clearContinuation() }
            }
        }
    }

    private func clearContinuation() {
        continuation = nil
    }
}
