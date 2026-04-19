//  MovieListHeaderView.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import SwiftUI
import Observation
import DesignSystem

public struct MovieListHeaderView: View {

    private let filterViewModel: MovieListFilterViewModel

    public init(
        filterViewModel: MovieListFilterViewModel
    ) {
        self.filterViewModel = filterViewModel
    }

    public var body: some View {
        @Bindable var filterViewModel = filterViewModel

        VStack(spacing: DSSpacing.lg) {
            SearchBarView(text: $filterViewModel.searchQuery)
                .padding(.horizontal)

            Text("Watch New Movies")
                .font(.title2.bold())
                .foregroundStyle(DSColor.accent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            if !filterViewModel.genreUIModels.isEmpty {
                genreStrip
            }
        }
    }

    private var genreStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.sm) {
                GenreChipView(
                    name: "All",
                    isSelected: filterViewModel.selectedGenreID == nil
                ) {
                    filterViewModel.clearGenreSelection()
                }
                ForEach(filterViewModel.genreUIModels) { genre in
                    GenreChipView(
                        name: genre.name,
                        isSelected: filterViewModel.selectedGenreID == genre.id
                    ) {
                        filterViewModel.toggleGenreSelection(id: genre.id)
                    }
                }
            }
            .padding()
        }
    }
}
