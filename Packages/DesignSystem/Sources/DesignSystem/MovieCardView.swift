//  MovieCardView.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import SwiftUI

public struct MovieCardView: View {

    let title: String
    let posterURL: URL?
    let rating: Double
    let year: Int?

    public init(title: String, posterURL: URL?, rating: Double, year: Int? = nil) {
        self.title = title
        self.posterURL = posterURL
        self.rating = rating
        self.year = year
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            CachedAsyncImage(
                url: posterURL,
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(2 / 3, contentMode: .fill)
                },
                placeholder: {
                    Rectangle()
                        .fill(DSColor.cardSurface)
                        .aspectRatio(2 / 3, contentMode: .fit)
                        .overlay(
                            Image(systemName: "film")
                                .foregroundStyle(DSColor.placeholderIcon)
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))

            Text(title)
                .font(DSFont.cardTitle)
                .lineLimit(2)

            if let year {
                Text(String(year))
                    .font(DSFont.cardRating)
                    .foregroundStyle(DSColor.textSecondary)
            }

            HStack(spacing: DSSpacing.ratingIconGap) {
                Image(systemName: "star.fill")
                    .font(DSFont.cardRating)
                    .foregroundStyle(DSColor.rating)
                Text(String(format: "%.1f", rating))
                    .font(DSFont.cardRating)
                    .foregroundStyle(DSColor.textSecondary)
            }
        }
    }
}
