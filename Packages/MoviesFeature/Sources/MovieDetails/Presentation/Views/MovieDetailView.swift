//  MovieDetailView.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import SwiftUI
import DesignSystem

public struct MovieDetailView: View {

    private var viewModel: MovieDetailViewModel
    @Environment(\.dismiss) private var dismiss
    private let autoLoadOnAppear: Bool

    public init(
        viewModel: MovieDetailViewModel,
        autoLoadOnAppear: Bool = true
    ) {
        self.viewModel = viewModel
        self.autoLoadOnAppear = autoLoadOnAppear
    }

    public var body: some View {
        Group {
            switch viewModel.viewState {
            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(DSColor.background)
            case .error(let message):
                DSContentUnavailableView(
                    style: .error(message: message) {
                        Task { await viewModel.load() }
                    }
                )
                .background(DSColor.background)
            case .empty:
                DSContentUnavailableView(
                    style: .empty(title: "No Details Available", message: "This movie has no details yet.")
                )
                .background(DSColor.background)
            case .loaded:
                if let uiModel = viewModel.uiModel {
                    detailContent(uiModel)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(DSFont.navIconBack)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if let title = viewModel.uiModel?.title {
                    ShareLink(item: title) {
                        Image(systemName: "square.and.arrow.up")
                            .font(DSFont.navIconShare)
                    }
                }
            }
        }
        .task {
            guard autoLoadOnAppear else { return }
            await viewModel.loadIfNeeded()
        }
    }

    @ViewBuilder
    private func detailContent(_ uiModel: MovieDetailUIModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                MovieDetailHeroView(imageURL: uiModel.heroPosterURL)
                MovieDetailHeaderView(uiModel: uiModel)
                MovieDetailBodyView(uiModel: uiModel)
            }
        }
        .refreshable { await viewModel.refresh() }
        .ignoresSafeArea(edges: .top)
        .background(DSColor.background)
    }
}
