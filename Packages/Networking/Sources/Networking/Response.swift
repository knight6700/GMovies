//  Response.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation

enum Response {
    static func validate(_ response: URLResponse) throws(NetworkError) -> HTTPURLResponse {
        guard let http = response as? HTTPURLResponse else {
            throw .invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw .http(http.statusCode)
        }
        return http
    }

    static func decode<T: Decodable>(
        _ data: Data,
        as type: T.Type = T.self,
        using decoder: JSONDecoder
    ) throws(NetworkError) -> T {
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw .decoding(error.localizedDescription)
        }
    }
}
