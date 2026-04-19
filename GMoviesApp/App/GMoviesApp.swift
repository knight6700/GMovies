//  GMoviesApp.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import SwiftUI

@MainActor
@main
struct GMoviesApp: App {
    private let container: AppDIContainer
    @State private var coordinator: AppCoordinator

    init() {
        let container = AppDIContainer(launchMode: .current)
        self.container = container
        self.coordinator = container.makeRootCoordinator()
    }

    var body: some Scene {
        WindowGroup {
            container.makeRootView(coordinator: coordinator)
        }
    }
}
