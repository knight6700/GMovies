//  MovieDetailBodyView.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import SwiftUI
import DesignSystem

public struct MovieDetailBodyView: View {

    public let uiModel: MovieDetailUIModel

    public init(uiModel: MovieDetailUIModel) {
        self.uiModel = uiModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let overview = uiModel.overview {
                Text(overview)
                    .font(DSFont.body)
                    .foregroundStyle(DSColor.textPrimary)
                    .lineSpacing(5)
                    .padding(.bottom, DSSpacing.xl)
            }

            Rectangle()
                .fill(DSColor.divider)
                .frame(height: DSSizing.hairlineHeight)
                .padding(.bottom, DSSpacing.headerHStack)

            MetadataGridView(uiModel: uiModel)

            if uiModel.showOfflineBanner {
                PartialDataBannerView()
                    .padding(.top, DSSpacing.lg)
            }
        }
        .padding(DSSpacing.lg)
        .background(DSColor.background)
    }
}

// MARK: - MetadataGridView

private struct MetadataGridView: View {

    let uiModel: MovieDetailUIModel

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: DSSpacing.lg, verticalSpacing: DSSpacing.sm) {
            if let url = uiModel.homepageURL {
                GridRow {
                    MetaLinkRow(label: "Homepage:", url: url, text: url.absoluteString)
                        .gridCellColumns(2)
                }
            }

            if let languages = uiModel.languages {
                GridRow {
                    MetaTextRow(label: "Languages:", value: languages)
                        .gridCellColumns(2)
                }
            }

            if uiModel.status != nil || uiModel.runtime != nil {
                GridRow {
                    if let status = uiModel.status {
                        MetaTextRow(label: "Status:", value: status)
                    } else {
                        Color.clear
                    }
                    if let runtime = uiModel.runtime {
                        MetaTextRow(label: "Runtime:", value: runtime)
                    } else {
                        Color.clear
                    }
                }
            }

            if uiModel.budget != nil || uiModel.revenue != nil {
                GridRow {
                    if let budget = uiModel.budget {
                        MetaTextRow(label: "Budget:", value: budget)
                    } else {
                        Color.clear
                    }
                    if let revenue = uiModel.revenue {
                        MetaTextRow(label: "Revenue:", value: revenue)
                    } else {
                        Color.clear
                    }
                }
            }

            if let releaseDate = uiModel.releaseDate {
                GridRow {
                    MetaTextRow(label: "Release:", value: releaseDate)
                        .gridCellColumns(2)
                }
            }
        }
    }
}

// MARK: - MetaTextRow

private struct MetaTextRow: View {

    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: DSSpacing.xxs) {
            Text(label)
                .font(DSFont.metaLabel)
                .foregroundStyle(DSColor.textPrimary)
            Text(value)
                .font(DSFont.metaValue)
                .foregroundStyle(DSColor.textMetaValue)
            Spacer(minLength: 0)
        }
    }
}

// MARK: - MetaLinkRow

private struct MetaLinkRow: View {

    let label: String
    let url: URL
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: DSSpacing.xxs) {
            Text(label)
                .font(DSFont.metaLabel)
                .foregroundStyle(DSColor.textPrimary)
            Link(text, destination: url)
                .font(DSFont.metaValue)
                .foregroundStyle(DSColor.textLink)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer(minLength: 0)
        }
    }
}

// MARK: - PartialDataBannerView

private struct PartialDataBannerView: View {

    var body: some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: "wifi.slash")
            Text("Some details unavailable offline. Open while online for full info.")
                .font(DSFont.bannerLabel)
        }
        .foregroundStyle(DSColor.textTertiary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DSSpacing.md)
        .background(DSColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
    }
}
