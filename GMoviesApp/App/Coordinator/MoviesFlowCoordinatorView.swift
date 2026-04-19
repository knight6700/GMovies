//  MoviesFlowCoordinatorView.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import SwiftUI

struct MoviesFlowCoordinatorView: View {

    @State var coordinator: MoviesFlowCoordinator
    let container: MoviesFlowDIContainer

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            container.makeMovieListScreen(router: coordinator)
                .navigationDestination(for: MoviesFlowCoordinator.Route.self) { route in
                    switch route {
                    case .movieDetail(let id, let preview):
                        container.makeMovieDetailScreen(id: id, preview: preview)
                    }
                }
        }
    }
}
