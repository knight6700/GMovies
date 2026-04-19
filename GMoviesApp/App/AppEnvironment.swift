//  AppEnvironment.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import OSLog

enum AppEnvironment: String, Sendable {
    case dev
    case staging
    case prod

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "GMovies",
        category: "AppEnvironment"
    )

    static var current: AppEnvironment {
        #if DEV
        return .dev
        #elseif STAGING
        return .staging
        #else
        return .prod
        #endif
    }

    var accessToken: String {
        Self.requiredInfoValue(for: "TMDBAccessToken")
    }

    var baseURL: String {
        Self.requiredInfoValue(for: "TMDBBaseURL")
    }

    var imageBaseURL: String {
        Self.requiredInfoValue(for: "TMDBImageBaseURL")
    }

    private static func requiredInfoValue(for key: String) -> String {
        guard let value = optionalInfoValue(for: key) else {
            let message = "Missing required Info.plist key: \(key)"
            logger.fault("\(message, privacy: .public)")
            fatalError(message)
        }
        return value
    }

    private static func optionalInfoValue(for key: String) -> String? {
        guard let value = Bundle.main.infoDictionary?[key] as? String else { return nil }
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty, !trimmedValue.hasPrefix("$(") else { return nil }
        return trimmedValue
    }
}
