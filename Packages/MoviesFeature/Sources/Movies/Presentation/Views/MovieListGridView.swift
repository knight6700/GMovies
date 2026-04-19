//  MovieListGridView.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import SwiftUI
import DesignSystem

public struct MovieListGridView: View {

    public let items: [MovieListItemUIModel]
    public let isLoadingMore: Bool
    public let pagingError: String?
    public let columns: [GridItem]
    public let onItemAppear: (MovieListItemUIModel) -> Void
    public let onRetry: () -> Void
    public let onSelectMovie: (Int) -> Void
    public let onRefresh: @Sendable () async -> Void

    public init(
        items: [MovieListItemUIModel],
        isLoadingMore: Bool,
        pagingError: String?,
        columns: [GridItem],
        onItemAppear: @escaping (MovieListItemUIModel) -> Void,
        onRetry: @escaping () -> Void,
        onSelectMovie: @escaping (Int) -> Void,
        onRefresh: @escaping @Sendable () async -> Void
    ) {
        self.items = items
        self.isLoadingMore = isLoadingMore
        self.pagingError = pagingError
        self.columns = columns
        self.onItemAppear = onItemAppear
        self.onRetry = onRetry
        self.onSelectMovie = onSelectMovie
        self.onRefresh = onRefresh
    }

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: DSSpacing.lg) {
                ForEach(items) { item in
                    Button {
                        onSelectMovie(item.id)
                    } label: {
                        MovieCardView(
                            title: item.title,
                            posterURL: item.posterURL,
                            rating: item.rating,
                            year: item.yearInt
                        )
                    }
                    .buttonStyle(.plain)
                    .onAppear { onItemAppear(item) }
                }
            }
            .padding(.horizontal)

            if isLoadingMore {
                ProgressView().padding()
            } else if let pagingError {
                VStack(spacing: DSSpacing.sm) {
                    Text(pagingError)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry", action: onRetry)
                        .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .refreshable {
            await onRefresh()
        }
    }
}
