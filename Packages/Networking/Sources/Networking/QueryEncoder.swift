//  QueryEncoder.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation

enum QueryEncoder {

    private static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    static func encode(_ value: any Encodable & Sendable) throws(NetworkError) -> [URLQueryItem] {
        let data = try toJSON(value)
        let dict = try toDictionary(data)
        return flatten(dict).sorted { $0.name == $1.name ? ($0.value ?? "") < ($1.value ?? "") : $0.name < $1.name }
    }
}

private extension QueryEncoder {

    static func toJSON(_ value: any Encodable & Sendable) throws(NetworkError) -> Data {
        do { return try jsonEncoder.encode(AnyEncodable(value)) }
        catch { throw .invalidURL }
    }

    static func toDictionary(_ data: Data) throws(NetworkError) -> [String: Any] {
        do {
            guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { throw NetworkError.invalidURL }
            return dict
        } catch { throw .invalidURL }
    }

    static func flatten(_ value: Any, prefix: String? = nil) -> [URLQueryItem] {
        switch value {
        case let dict as [String: Any]:
            return dict.flatMap { key, val in
                flatten(val, prefix: prefix.map { "\($0)[\(key)]" } ?? key)
            }
        case let array as [Any]:
            guard let prefix else { return [] }
            return array.flatMap { flatten($0, prefix: prefix) }
        case is NSNull:
            return []
        default:
            guard let prefix else { return [] }
            return [URLQueryItem(name: prefix, value: stringValue(value))]
        }
    }

    static func stringValue(_ value: Any) -> String {
        if let number = value as? NSNumber {
            return number.isBool ? String(number.boolValue) : number.stringValue
        }
        return value as? String ?? String(describing: value)
    }
}

private extension NSNumber {
    var isBool: Bool { CFBooleanGetTypeID() == CFGetTypeID(self) }
}

private struct AnyEncodable: Encodable {
    private let encode: @Sendable (Encoder) throws -> Void

    init(_ value: any Encodable & Sendable) {
        self.encode = { try value.encode(to: $0) }
    }

    func encode(to encoder: Encoder) throws {
        try encode(encoder)
    }
}
