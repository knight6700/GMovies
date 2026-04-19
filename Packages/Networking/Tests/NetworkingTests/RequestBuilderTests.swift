//  RequestBuilderTests.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import Testing
@testable import Networking

private struct TestQuery: Encodable, Sendable {
    let page: Int
    let includeAdult: Bool
}

private struct SimpleRequest: Request {
    var path: String = "/movies"
    var method: HTTPMethod = .get
    var query: (any Encodable & Sendable)?
    var headers: [String: String] = [:]
    var body: Data?
    var requiresAuth: Bool = true
}

@Suite("RequestBuilder")
struct RequestBuilderTests {

    private let config = APIConfiguration(baseURL: "https://api.example.com/v3", accessToken: "test-token")

    @Test
    func buildsCorrectURL() throws {
        let request = try RequestBuilder.build(SimpleRequest(path: "/movies/42"), config: config, timeout: 10)
        #expect(request.url?.absoluteString == "https://api.example.com/v3/movies/42")
    }

    @Test
    func encodesQueryParameters() throws {
        let request = try RequestBuilder.build(
            SimpleRequest(query: TestQuery(page: 1, includeAdult: false)),
            config: config, timeout: 10
        )
        let query = request.url?.query ?? ""
        #expect(query.contains("page=1"))
        #expect(query.contains("include_adult=false"))
    }

    @Test
    func distinguishesIntFromBool() throws {
        let request = try RequestBuilder.build(
            SimpleRequest(query: TestQuery(page: 1, includeAdult: true)),
            config: config, timeout: 10
        )
        let query = request.url?.query ?? ""
        #expect(query.contains("page=1"))
        #expect(query.contains("include_adult=true"))
    }

    @Test
    func setsAuthHeader() throws {
        let request = try RequestBuilder.build(SimpleRequest(requiresAuth: true), config: config, timeout: 10)
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer test-token")
    }

    @Test
    func omitsAuthHeader() throws {
        let request = try RequestBuilder.build(SimpleRequest(requiresAuth: false), config: config, timeout: 10)
        #expect(request.value(forHTTPHeaderField: "Authorization") == nil)
    }

    @Test
    func setsHTTPMethod() throws {
        let request = try RequestBuilder.build(SimpleRequest(method: .post), config: config, timeout: 10)
        #expect(request.httpMethod == "POST")
    }

    @Test
    func setsTimeout() throws {
        let request = try RequestBuilder.build(SimpleRequest(), config: config, timeout: 30)
        #expect(request.timeoutInterval == 30)
    }

    @Test
    func setsCustomHeaders() throws {
        let request = try RequestBuilder.build(
            SimpleRequest(headers: ["X-Custom": "value"]), config: config, timeout: 10
        )
        #expect(request.value(forHTTPHeaderField: "X-Custom") == "value")
    }

    @Test
    func throwsForBadURL() {
        let badConfig = APIConfiguration(baseURL: "://bad", accessToken: "x")
        do {
            _ = try RequestBuilder.build(SimpleRequest(), config: badConfig, timeout: 10)
            Issue.record("Expected invalidURL")
        } catch {
            #expect(error == .invalidURL)
        }
    }
}
