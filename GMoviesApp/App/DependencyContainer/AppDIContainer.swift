//  AppDIContainer.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import SwiftUI

@MainActor
final class AppDIContainer {

    private let dependencies: AppDependencies
    private let launchMode: AppLaunchMode
    private let splashDuration: TimeInterval
    private lazy var moviesFlow = MoviesFlowDIContainer(
        dependencies: dependencies,
        autoLoadFeatureContent: launchMode.autoLoadsFeatureContent
    )

    init(
        environment: AppEnvironment = .current,
        session: URLSession = .shared,
        launchMode: AppLaunchMode = .standard,
        splashDuration: TimeInterval = AppLaunchMode.currentSplashDuration
    ) {
        self.dependencies = AppDependencies(
            environment: environment,
            session: session
        )
        self.launchMode = launchMode
        self.splashDuration = splashDuration
    }

    func makeRootCoordinator() -> AppCoordinator {
        AppCoordinator(
            moviesCoordinator: moviesFlow.makeCoordinator()
        )
    }

    func makeRootView(coordinator: AppCoordinator) -> some View {
        AppCoordinatorView(
            container: self,
            coordinator: coordinator,
            showsSplashScreen: launchMode.showsSplashScreen,
            splashDuration: splashDuration
        )
    }

    func makeMoviesFlowView(coordinator: MoviesFlowCoordinator) -> some View {
        MoviesFlowCoordinatorView(
            coordinator: coordinator,
            container: moviesFlow
        )
    }
}
