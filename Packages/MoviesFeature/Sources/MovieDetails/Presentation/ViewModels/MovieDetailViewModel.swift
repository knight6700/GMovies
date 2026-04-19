//  MovieDetailViewModel.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import Utilities
import OSLog


@MainActor
@Observable
public final class MovieDetailViewModel {

    public var uiModel: MovieDetailUIModel?
    public var viewState: ViewState = .idle

    private let movieID: Int
    private let repository: any MovieDetailsRepository
    private let movieDetailUIMapper: MovieDetailUIMapper
    private let fallbackPreviewUIModel: MovieDetailUIModel?
    private var hasAttemptedLoad = false
    private var isRefreshing = false

    public init(
        movieID: Int,
        repository: any MovieDetailsRepository,
        fallbackData: MovieDetailFallbackData? = nil,
        imageURLBuilder: any ImageURLBuilding = ImageURLBuilder(baseURL: "")
    ) {
        let mapper = MovieDetailUIMapper(imageURLBuilder: imageURLBuilder)
        self.movieID = movieID
        self.repository = repository
        self.movieDetailUIMapper = mapper
        self.fallbackPreviewUIModel = fallbackData.map { mapper.map($0) }
    }

    public func loadIfNeeded() async {
        guard !hasAttemptedLoad else { return }
        await load(force: true)
    }

    public func load(force: Bool = false) async {
        if force {
            guard viewState != .loading else { return }
        } else {
            switch viewState {
            case .idle, .error: break
            case .loading, .loaded, .empty: return
            }
        }
        hasAttemptedLoad = true
        Logger.movieDetail.info("load id=\(self.movieID) → loading")
        viewState = .loading
        await performLoad()
    }

    public func refresh() async {
        guard viewState != .loading, !isRefreshing else { return }
        Logger.movieDetail.info("refresh id=\(self.movieID) → started")
        isRefreshing = true
        defer { isRefreshing = false }
        await performRefresh()
    }

    private func performLoad() async {
        do {
            let detail = try await repository.getMovieDetail(id: movieID)
            try Task.checkCancellation()
            uiModel = movieDetailUIMapper.map(detail)
            Logger.movieDetail.info("load id=\(self.movieID) → loaded")
            viewState = .loaded
        } catch is CancellationError {
            Logger.movieDetail.info("load id=\(self.movieID) cancelled")
            hasAttemptedLoad = false
            viewState = .idle
        } catch {
            Logger.movieDetail.error("load id=\(self.movieID) failed: \(error.localizedDescription, privacy: .public)")
            if uiModel == nil, let fallbackPreviewUIModel {
                uiModel = fallbackPreviewUIModel
                Logger.movieDetail.info("load id=\(self.movieID) → loaded from preview fallback")
                viewState = .loaded
            } else {
                viewState = .error(error.localizedDescription)
            }
        }
    }

    private func performRefresh() async {
        let previousState = viewState

        do {
            let detail = try await repository.refreshMovieDetail(id: movieID)
            try Task.checkCancellation()
            uiModel = movieDetailUIMapper.map(detail)
            Logger.movieDetail.info("refresh id=\(self.movieID) → loaded")
            viewState = .loaded
        } catch is CancellationError {
            Logger.movieDetail.info("refresh id=\(self.movieID) cancelled")
        } catch {
            Logger.movieDetail.error("refresh id=\(self.movieID) failed: \(error.localizedDescription, privacy: .public)")
            if uiModel != nil {
                viewState = previousState
            } else if let fallbackPreviewUIModel {
                uiModel = fallbackPreviewUIModel
                viewState = .loaded
            } else {
                viewState = .error(error.localizedDescription)
            }
        }
    }

}
