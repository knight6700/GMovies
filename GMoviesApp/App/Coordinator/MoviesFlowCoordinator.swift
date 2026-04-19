//  MoviesFlowCoordinator.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import SwiftUI
import Movies

@MainActor
@Observable
final class MoviesFlowCoordinator {

    var path = NavigationPath()

    enum Route: Hashable {
        case movieDetail(id: Int, preview: MovieDetailPreviewData?)
    }

    func showMovieDetails(id: Int, preview: MovieDetailPreviewData? = nil) {
        path.append(Route.movieDetail(id: id, preview: preview))
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}

extension MoviesFlowCoordinator: MovieListRouting {
    func goToMovieDetails(id: Int, preview: MovieDetailPreviewData? = nil) {
        showMovieDetails(id: id, preview: preview)
    }
}
