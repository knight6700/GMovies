//  MovieDetailUIMapper.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import Utilities

struct MovieDetailUIMapper {
    private let imageURLBuilder: any ImageURLBuilding

    init(imageURLBuilder: any ImageURLBuilding) {
        self.imageURLBuilder = imageURLBuilder
    }

    func map(_ detail: MovieDetail) -> MovieDetailUIModel {
        MovieDetailUIModel(
            posterPath: detail.posterPath,
            thumbnailPosterURL: imageURLBuilder.url(for: detail.posterPath, size: .w185),
            heroPosterURL: imageURLBuilder.url(for: detail.posterPath, size: .w500),
            title: detail.title,
            titleWithYear: formatTitleWithYear(detail.title, releaseDate: detail.releaseDate),
            genres: detail.genres.isEmpty ? nil : detail.genres.map(\.name).joined(separator: ", "),
            overview: detail.overview.isEmpty ? nil : detail.overview,
            homepageURL: detail.homepage.flatMap(URL.init(string:)),
            languages: detail.spokenLanguages.isEmpty ? nil : detail.spokenLanguages.joined(separator: ", "),
            status: detail.status.isEmpty ? nil : detail.status,
            runtime: detail.runtime.map { "\($0) minutes" },
            budget: detail.budget > 0 ? Formatters.currency(detail.budget) : nil,
            revenue: detail.revenue > 0 ? Formatters.currency(detail.revenue) : nil,
            releaseDate: detail.releaseDate.flatMap {
                $0.isEmpty ? nil : Formatters.releaseDate($0)
            },
            showOfflineBanner: detail.isPartialOfflineData
        )
    }

    func map(_ fallbackData: MovieDetailFallbackData) -> MovieDetailUIModel {
        MovieDetailUIModel(
            posterPath: fallbackData.posterPath,
            thumbnailPosterURL: imageURLBuilder.url(for: fallbackData.posterPath, size: .w185),
            heroPosterURL: imageURLBuilder.url(for: fallbackData.posterPath, size: .w500),
            title: fallbackData.title,
            titleWithYear: formatTitleWithYear(fallbackData.title, releaseYear: fallbackData.releaseYear),
            genres: nil,
            overview: fallbackData.overview,
            homepageURL: nil,
            languages: nil,
            status: nil,
            runtime: nil,
            budget: nil,
            revenue: nil,
            releaseDate: nil,
            showOfflineBanner: true
        )
    }

    private func formatTitleWithYear(_ title: String, releaseDate: String?) -> String {
        guard let dateStr = releaseDate,
              dateStr.count >= 4,
              Int(dateStr.prefix(4)) != nil else { return title }
        return "\(title) (\(dateStr.prefix(4)))"
    }

    private func formatTitleWithYear(_ title: String, releaseYear: Int?) -> String {
        guard let releaseYear else { return title }
        return "\(title) (\(releaseYear))"
    }
}
