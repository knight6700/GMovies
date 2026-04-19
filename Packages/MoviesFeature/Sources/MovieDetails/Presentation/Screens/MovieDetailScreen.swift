//  MovieDetailScreen.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import SwiftUI

public struct MovieDetailScreen: View {

    @State private var viewModel: MovieDetailViewModel
    private let autoLoadOnAppear: Bool

    public init(
        viewModel: MovieDetailViewModel,
        autoLoadOnAppear: Bool = true
    ) {
        self.viewModel = viewModel
        self.autoLoadOnAppear = autoLoadOnAppear
    }

    public var body: some View {
        MovieDetailView(
            viewModel: viewModel,
            autoLoadOnAppear: autoLoadOnAppear
        )
    }
}
