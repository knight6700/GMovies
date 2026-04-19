//  ConnectionStatus.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

public protocol ConnectionStatus: Sendable {
    var isConnected: Bool { get async }
}

public protocol ConnectionObserving: ConnectionStatus {
    func updates() async -> AsyncStream<Bool>
}
