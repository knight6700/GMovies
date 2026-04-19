//  NetworkError.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation

public enum NetworkError: LocalizedError, Equatable {
    case invalidURL
    case transport(URLError)
    case http(Int)
    case decoding(String)
    case invalidResponse

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "We couldn't reach the server. Please try again later."
        case .transport(let urlError):
            return Self.message(for: urlError)
        case .http(let code):
            return Self.message(forStatus: code)
        case .decoding:
            return "We received an unexpected response. Please try again."
        case .invalidResponse:
            return "The server returned an invalid response. Please try again."
        }
    }

    public var isRetryable: Bool {
        switch self {
        case .invalidURL, .decoding: return false
        case .invalidResponse:       return true
        case .transport(let err):
            switch err.code {
            case .cancelled, .userAuthenticationRequired: return false
            default: return true
            }
        case .http(let code):
            return code >= 500 || code == 408 || code == 429
        }
    }

    private static func message(for urlError: URLError) -> String {
        switch urlError.code {
        case .notConnectedToInternet, .dataNotAllowed:
            return "You're offline. Check your connection and try again."
        case .networkConnectionLost:
            return "Your connection was lost. Reconnecting…"
        case .timedOut:
            return "The request timed out. Please try again."
        case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
            return "We couldn't reach the server. Please try again later."
        case .cancelled:
            return "Request cancelled."
        case .secureConnectionFailed, .serverCertificateUntrusted,
             .serverCertificateHasBadDate, .serverCertificateNotYetValid,
             .serverCertificateHasUnknownRoot, .clientCertificateRejected,
             .clientCertificateRequired:
            return "Secure connection failed. Please try again."
        default:
            return "Network error. Please try again."
        }
    }

    private static func message(forStatus code: Int) -> String {
        switch code {
        case 400:       return "Something went wrong with the request."
        case 401, 403:  return "You're not authorized to access this content."
        case 404:       return "We couldn't find what you're looking for."
        case 408:       return "The request timed out. Please try again."
        case 429:       return "Too many requests. Please wait a moment."
        case 500...599: return "Our servers are having issues. Please try again later."
        default:        return "Network error (\(code)). Please try again."
        }
    }
}
