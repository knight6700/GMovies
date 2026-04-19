//  AppDependencies.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import Networking
import Utilities
import DesignSystem

@MainActor
final class AppDependencies {

    let environment: AppEnvironment
    let apiClient: URLSessionHTTPClient
    let connectivity: ConnectionMonitor
    let imagePrefetcher: ImagePrefetcher
    let imageURLBuilder: ImageURLBuilder

    init(
        environment: AppEnvironment = .current,
        session: URLSession = .shared
    ) {
        self.environment = environment
        self.imageURLBuilder = ImageURLBuilder(baseURL: environment.imageBaseURL)
        self.apiClient = URLSessionHTTPClient(
            config: APIConfiguration(
                baseURL: environment.baseURL,
                accessToken: environment.accessToken
            ),
            session: session
        )
        self.connectivity = ConnectionMonitor()
        self.imagePrefetcher = ImagePrefetcher(
            cache: ImageCache.shared,
            registry: InFlightRegistry.shared,
            session: .imagePrefetch
        )
    }
}
