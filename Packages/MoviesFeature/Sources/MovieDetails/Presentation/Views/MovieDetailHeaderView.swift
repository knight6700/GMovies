//  MovieDetailHeaderView.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import SwiftUI
import DesignSystem

public struct MovieDetailHeaderView: View {

    public let uiModel: MovieDetailUIModel

    public init(uiModel: MovieDetailUIModel) {
        self.uiModel = uiModel
    }

    public var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.headerHStack) {
            CachedAsyncImage(
                url: uiModel.thumbnailPosterURL,
                content: { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                },
                placeholder: {
                    Rectangle().fill(DSColor.surface)
                }
            )
            .frame(width: DSSizing.thumbnailWidth, height: DSSizing.thumbnailHeight)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
            .shadow(color: DSColor.background.opacity(0.4), radius: 4)

            VStack(alignment: .leading, spacing: DSSpacing.headerVStack) {
                Text(uiModel.titleWithYear)
                    .font(DSFont.heroTitle)
                    .foregroundStyle(DSColor.textPrimary)

                if let genres = uiModel.genres {
                    Text(genres)
                        .font(DSFont.body)
                        .foregroundStyle(DSColor.textSecondary)
                        .lineLimit(3)
                }
            }
            .padding(.top, DSSpacing.xs)

            Spacer(minLength: 0)
        }
        .padding(DSSpacing.lg)
        .background(DSColor.background)
    }
}
