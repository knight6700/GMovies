//  MovieDetailHeroView.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import SwiftUI
import DesignSystem

public struct MovieDetailHeroView: View {

    private let imageURL: URL?

    public init(imageURL: URL?) {
        self.imageURL = imageURL
    }

    public var body: some View {
        CachedAsyncImage(
            url: imageURL,
            content: { image in
                image.resizable().aspectRatio(contentMode: .fill)
            },
            placeholder: {
                Rectangle()
                    .fill(DSColor.surface)
                    .overlay(
                        Image(systemName: "film")
                            .font(.largeTitle)
                            .foregroundStyle(DSColor.placeholderIcon)
                    )
            }
        )
        .frame(maxWidth: .infinity)
        .frame(height: DSSizing.heroHeight)
        .clipped()
        .overlay(alignment: .bottom) {
            LinearGradient(
                colors: [.clear, DSColor.background.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: DSSizing.heroGradient)
        }
    }
}
