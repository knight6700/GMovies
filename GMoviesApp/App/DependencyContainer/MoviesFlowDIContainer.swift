//  MoviesFlowDIContainer.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import SwiftUI
import Movies
import MovieDetails

@MainActor
final class MoviesFlowDIContainer {

    private let moviesDI: MoviesDIContainer
    private let movieDetailsDI: MovieDetailsDIContainer

    init(
        dependencies: AppDependencies,
        autoLoadFeatureContent: Bool = true
    ) {
        self.moviesDI = MoviesDIContainer(
            apiClient: dependencies.apiClient,
            connectivity: dependencies.connectivity,
            imagePrefetcher: dependencies.imagePrefetcher,
            imageURLBuilder: dependencies.imageURLBuilder,
            autoLoadOnAppear: autoLoadFeatureContent
        )

        self.movieDetailsDI = MovieDetailsDIContainer(
            apiClient: dependencies.apiClient,
            connectivity: dependencies.connectivity,
            imageURLBuilder: dependencies.imageURLBuilder,
            autoLoadOnAppear: autoLoadFeatureContent
        )
    }

    func makeCoordinator() -> MoviesFlowCoordinator {
        MoviesFlowCoordinator()
    }

    func makeMovieListScreen(router: any MovieListRouting) -> some View {
        moviesDI.makeMovieListScreen(router: router)
    }

    func makeMovieDetailScreen(id: Int, preview: MovieDetailPreviewData?) -> some View {
        movieDetailsDI.makeMovieDetailScreen(
            movieID: id,
            fallbackData: preview.map(mapMovieDetailFallback)
        )
    }

    private func mapMovieDetailFallback(_ preview: MovieDetailPreviewData) -> MovieDetailFallbackData {
        MovieDetailFallbackData(
            title: preview.title,
            posterPath: preview.posterPath,
            releaseYear: preview.releaseYear,
            overview: preview.overview
        )
    }
}
