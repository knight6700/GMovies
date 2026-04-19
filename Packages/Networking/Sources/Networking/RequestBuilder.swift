//  RequestBuilder.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation

enum RequestBuilder {

    static func build(
        _ request: any Request,
        config: APIConfiguration,
        timeout: TimeInterval
    ) throws(NetworkError) -> URLRequest {
        var urlRequest = URLRequest(url: try buildURL(request, config: config))
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        urlRequest.timeoutInterval = timeout
        applyHeaders(to: &urlRequest, request: request, config: config)
        return urlRequest
    }
}

private extension RequestBuilder {

    static func buildURL(
        _ request: any Request,
        config: APIConfiguration
    ) throws(NetworkError) -> URL {
        guard let baseURL = URL(string: config.baseURL),
              var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        else { throw .invalidURL }

        components.path = joinPath(base: components.path, endpoint: request.path)

        if let query = request.query {
            let items = try QueryEncoder.encode(query)
            if !items.isEmpty {
                components.queryItems = (components.queryItems ?? []) + items
            }
        }

        guard let url = components.url else { throw .invalidURL }
        return url
    }

    static func joinPath(base: String, endpoint: String) -> String {
        let parts = [
            base.trimmingCharacters(in: CharacterSet(charactersIn: "/")),
            endpoint.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        ].filter { !$0.isEmpty }
        return parts.isEmpty ? "/" : "/" + parts.joined(separator: "/")
    }

    static func applyHeaders(
        to request: inout URLRequest,
        request endpoint: any Request,
        config: APIConfiguration
    ) {
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if endpoint.requiresAuth {
            request.setValue("Bearer \(config.accessToken)", forHTTPHeaderField: "Authorization")
        }
        for (name, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: name)
        }
    }
}
