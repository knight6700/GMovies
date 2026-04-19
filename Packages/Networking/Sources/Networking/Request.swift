//  Request.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation

public protocol Request: Sendable {
    var path: String { get }
    var method: HTTPMethod { get }
    var query: (any Encodable & Sendable)? { get }
    var headers: [String: String] { get }
    var body: Data? { get }
    var requiresAuth: Bool { get }
}

public extension Request {
    var method: HTTPMethod { .get }
    var query: (any Encodable & Sendable)? { nil }
    var headers: [String: String] { [:] }
    var body: Data? { nil }
    var requiresAuth: Bool { true }
}
