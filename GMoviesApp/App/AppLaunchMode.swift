//  AppLaunchMode.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation

enum AppLaunchMode: String {
    case standard
    case testing

    static let environmentKey = "GMOVIES_BOOTSTRAP_MODE"
    static let splashDurationEnvironmentKey = "GMOVIES_SPLASH_DURATION"
    static let defaultSplashDuration: TimeInterval = 1.2

    init(environment: [String: String]) {
        self = environment[Self.environmentKey]
            .flatMap(Self.init(rawValue:))
            ?? .standard
    }

    static var current: AppLaunchMode {
        AppLaunchMode(environment: ProcessInfo.processInfo.environment)
    }

    static var currentSplashDuration: TimeInterval {
        splashDuration(environment: ProcessInfo.processInfo.environment)
    }

    static func splashDuration(environment: [String: String]) -> TimeInterval {
        guard let rawValue = environment[Self.splashDurationEnvironmentKey] else {
            return defaultSplashDuration
        }

        guard let duration = TimeInterval(rawValue), duration >= 0 else {
            return defaultSplashDuration
        }

        return duration
    }

    var autoLoadsFeatureContent: Bool { self == .standard }
    var showsSplashScreen: Bool { self == .standard }
}
