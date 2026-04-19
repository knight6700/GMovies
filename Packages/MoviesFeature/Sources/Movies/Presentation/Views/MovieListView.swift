//  MovieListView.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import SwiftUI
import DesignSystem

public struct MovieListView: View {

    private var viewModel: MovieListViewModel
    private let onSelectMovie: (Int, MovieDetailPreviewData?) -> Void
    private let autoLoadOnAppear: Bool

    private let columns = [
        GridItem(.flexible(), spacing: DSSpacing.md),
        GridItem(.flexible(), spacing: DSSpacing.md)
    ]

    public init(
        viewModel: MovieListViewModel,
        onSelectMovie: @escaping (Int, MovieDetailPreviewData?) -> Void,
        autoLoadOnAppear: Bool = true
    ) {
        self.viewModel = viewModel
        self.onSelectMovie = onSelectMovie
        self.autoLoadOnAppear = autoLoadOnAppear
    }

    public var body: some View {
        Group {
            switch viewModel.viewState {
            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .error(let message):
                DSContentUnavailableView(
                    style: .error(message: message) {
                        Task { await viewModel.loadInitial() }
                    }
                )
            case .empty:
                DSContentUnavailableView(
                    style: .empty(
                        title: "No Movies Found",
                        message: "Check back later for new titles."
                    )
                )
            case .loaded:
                loadedContent
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if viewModel.isOffline {
                OfflineBannerView()
            }
        }
        .task {
            guard autoLoadOnAppear else { return }
            await viewModel.loadIfNeeded()
        }
    }

    private var loadedContent: some View {
        VStack(spacing: DSSpacing.lg) {
            MovieListHeaderView(
                filterViewModel: viewModel.filterViewModel
            )
            .padding(.top, DSSpacing.sm)

            if viewModel.filteredUIModels.isEmpty {
                DSContentUnavailableView(
                    style: .empty(
                        title: "No Results",
                        message: "No movies match your current search or filter."
                    )
                )
            } else {
                MovieListGridView(
                    items: viewModel.filteredUIModels,
                    isLoadingMore: viewModel.isLoadingMore,
                    pagingError: viewModel.pagingError,
                    columns: columns,
                    onItemAppear: { item in
                        Task { await viewModel.loadNextPageIfNeeded(currentItemID: item.id) }
                        viewModel.prefetchImages(after: item.id)
                    },
                    onRetry: { Task { await viewModel.retryNextPage() } },
                    onSelectMovie: { id in
                        onSelectMovie(id, viewModel.preview(for: id))
                    },
                    onRefresh: { await viewModel.refresh() }
                )
            }
        }
    }
}
