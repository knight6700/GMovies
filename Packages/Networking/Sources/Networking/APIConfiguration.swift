//  APIConfiguration.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

public struct APIConfiguration: Sendable {
    public let baseURL: String
    public let accessToken: String

    public init(baseURL: String, accessToken: String) {
        self.baseURL = baseURL
        self.accessToken = accessToken
    }
}
