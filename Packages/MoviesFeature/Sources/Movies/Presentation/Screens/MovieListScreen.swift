//  MovieListScreen.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import SwiftUI

public struct MovieListScreen: View {

    @State private var viewModel: MovieListViewModel
    private let router: any MovieListRouting
    private let autoLoadOnAppear: Bool

    public init(
        viewModel: MovieListViewModel,
        router: any MovieListRouting,
        autoLoadOnAppear: Bool = true
    ) {
        self.viewModel = viewModel
        self.router = router
        self.autoLoadOnAppear = autoLoadOnAppear
    }

    public var body: some View {
        MovieListView(
            viewModel: viewModel,
            onSelectMovie: { id, preview in
                router.goToMovieDetails(id: id, preview: preview)
            },
            autoLoadOnAppear: autoLoadOnAppear
        )
    }
}
