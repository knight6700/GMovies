//  URLSessionHTTPClientTests.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import Testing
@testable import Networking

private struct StubModel: Decodable, Equatable {
    let id: Int
    let name: String
}

private struct StubRequest: Request {
    let path: String
    var query: (any Encodable & Sendable)? { nil }
    static let any = StubRequest(path: "/test")
}

@Suite("URLSessionHTTPClient", .serialized)
struct URLSessionHTTPClientTests {

    private func makeClient(
        baseURL: String = "https://api.test.com",
        maxRetries: Int = 0,
        timeout: TimeInterval = 5
    ) -> URLSessionHTTPClient {
        URLSessionHTTPClient(
            config: APIConfiguration(baseURL: baseURL, accessToken: "token"),
            session: .stubbed(),
            maxRetries: maxRetries,
            timeout: timeout,
            baseRetryDelay: 0.01
        )
    }

    private func stubSuccess(json: String, statusCode: Int = 200) {
        MockURLProtocol.handler = { request in
            let response = HTTPURLResponse(
                url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil
            )!
            return (response, Data(json.utf8))
        }
    }

    @Test
    func buildsCorrectRequest() async throws {
        defer { MockURLProtocol.handler = nil }

        try await confirmation(expectedCount: 1) { confirm in
            MockURLProtocol.handler = { request in
                confirm()
                #expect(request.url?.path == "/test")
                #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer token")
                #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
                return (
                    HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!,
                    Data(#"{"id":1,"name":"OK"}"#.utf8)
                )
            }
            let _: StubModel = try await makeClient().send(StubRequest.any)
        }
    }

    @Test
    func decodesValidJSON() async throws {
        defer { MockURLProtocol.handler = nil }
        stubSuccess(json: #"{"id":42,"name":"Mahmoud"}"#)

        let result: StubModel = try await makeClient().send(StubRequest.any)
        #expect(result == StubModel(id: 42, name: "Mahmoud"))
    }

    @Test
    func throwsDecodingErrorForInvalidJSON() async {
        defer { MockURLProtocol.handler = nil }
        stubSuccess(json: #"{"invalid": true}"#)

        do {
            let _: StubModel = try await makeClient().send(StubRequest.any)
            Issue.record("Expected decoding error")
        } catch let error as NetworkError {
            guard case .decoding = error else {
                Issue.record("Expected .decoding, got \(error)")
                return
            }
        }
    }

    @Test
    func throwsHTTPErrorFor4xx() async {
        defer { MockURLProtocol.handler = nil }
        stubSuccess(json: #"{}"#, statusCode: 400)

        do {
            let _: StubModel = try await makeClient().send(StubRequest.any)
            Issue.record("Expected http error")
        } catch let error as NetworkError {
            #expect(error == .http(400))
        }
    }

    @Test
    func throwsHTTPErrorFor5xx() async {
        defer { MockURLProtocol.handler = nil }
        stubSuccess(json: #"{}"#, statusCode: 500)

        do {
            let _: StubModel = try await makeClient().send(StubRequest.any)
            Issue.record("Expected http error")
        } catch let error as NetworkError {
            #expect(error == .http(500))
        }
    }

    @Test
    func throwsTransportErrorForNetworkFailure() async {
        defer { MockURLProtocol.handler = nil }
        MockURLProtocol.handler = { _ in throw URLError(.notConnectedToInternet) }

        do {
            let _: StubModel = try await makeClient().send(StubRequest.any)
            Issue.record("Expected transport error")
        } catch let error as NetworkError {
            guard case .transport(let urlError) = error else {
                Issue.record("Expected .transport, got \(error)")
                return
            }
            #expect(urlError.code == .notConnectedToInternet)
        }
    }

    @Test
    func throwsTransportErrorForTimeout() async {
        defer { MockURLProtocol.handler = nil }
        MockURLProtocol.handler = { _ in throw URLError(.timedOut) }

        do {
            let _: StubModel = try await makeClient().send(StubRequest.any)
            Issue.record("Expected timeout error")
        } catch let error as NetworkError {
            guard case .transport(let urlError) = error else {
                Issue.record("Expected .transport, got \(error)")
                return
            }
            #expect(urlError.code == .timedOut)
        }
    }

    @Test
    func retriesOnServerError() async throws {
        defer { MockURLProtocol.handler = nil }
        var attempts = 0

        MockURLProtocol.handler = { request in
            attempts += 1
            let code = attempts == 1 ? 500 : 200
            let body = attempts == 1 ? #"{}"# : #"{"id":1,"name":"retry"}"#
            return (
                HTTPURLResponse(url: request.url!, statusCode: code, httpVersion: nil, headerFields: nil)!,
                Data(body.utf8)
            )
        }

        let result: StubModel = try await makeClient(maxRetries: 1).send(StubRequest.any)
        #expect(result == StubModel(id: 1, name: "retry"))
        #expect(attempts == 2)
    }

    @Test
    func doesNotRetryOn4xx() async {
        defer { MockURLProtocol.handler = nil }
        var attempts = 0

        MockURLProtocol.handler = { request in
            attempts += 1
            return (
                HTTPURLResponse(url: request.url!, statusCode: 400, httpVersion: nil, headerFields: nil)!,
                Data(#"{}"#.utf8)
            )
        }

        do {
            let _: StubModel = try await makeClient(maxRetries: 2).send(StubRequest.any)
            Issue.record("Expected error")
        } catch {
            #expect(attempts == 1)
        }
    }

    @Test
    func exhaustsRetriesAndThrows() async {
        defer { MockURLProtocol.handler = nil }
        var attempts = 0

        MockURLProtocol.handler = { request in
            attempts += 1
            return (
                HTTPURLResponse(url: request.url!, statusCode: 503, httpVersion: nil, headerFields: nil)!,
                Data(#"{}"#.utf8)
            )
        }

        do {
            let _: StubModel = try await makeClient(maxRetries: 2).send(StubRequest.any)
            Issue.record("Expected error after exhausting retries")
        } catch let error as NetworkError {
            #expect(error == .http(503))
            #expect(attempts == 3)
        }
    }
}
