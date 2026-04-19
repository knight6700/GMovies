//  AppCoordinatorView.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import SwiftUI

struct AppCoordinatorView: View {

    let container: AppDIContainer
    let coordinator: AppCoordinator
    let showsSplashScreen: Bool
    let splashDuration: TimeInterval
    @State private var isShowingSplash: Bool

    init(
        container: AppDIContainer,
        coordinator: AppCoordinator,
        showsSplashScreen: Bool,
        splashDuration: TimeInterval
    ) {
        self.container = container
        self.coordinator = coordinator
        self.showsSplashScreen = showsSplashScreen
        self.splashDuration = splashDuration
        _isShowingSplash = State(initialValue: showsSplashScreen)
    }

    var body: some View {
        container.makeMoviesFlowView(coordinator: coordinator.moviesCoordinator)
            .overlay {
                if isShowingSplash {
                    AppSplashView()
                        .transition(.opacity)
                }
            }
            .task {
                await dismissSplashIfNeeded()
            }
    }

    private func dismissSplashIfNeeded() async {
        guard showsSplashScreen else { return }
        if splashDuration > 0 {
            let nanoseconds = UInt64(splashDuration * 1_000_000_000)
            try? await Task.sleep(nanoseconds: nanoseconds)
        }
        guard !Task.isCancelled else { return }
        withAnimation(.easeOut(duration: 0.3)) {
            isShowingSplash = false
        }
    }
}
