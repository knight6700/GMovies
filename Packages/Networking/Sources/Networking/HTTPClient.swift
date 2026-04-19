//  HTTPClient.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

public protocol HTTPClient: Sendable {
    func send<T: Decodable>(_ request: any Request) async throws -> T
}
