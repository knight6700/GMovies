//  DSContentUnavailableView.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import SwiftUI

public struct DSContentUnavailableView: View {

    public enum Style {
        case error(message: String, retry: () -> Void)
        case empty(title: String, message: String)
    }

    private let style: Style

    public init(style: Style) {
        self.style = style
    }

    public var body: some View {
        Group {
            switch style {
            case .error(let message, let retry):
                ContentUnavailableView {
                    Label("Something Went Wrong", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(message)
                } actions: {
                    Button("Try Again", action: retry)
                        .buttonStyle(.borderedProminent)
                        .tint(DSColor.primary)
                }

            case .empty(let title, let message):
                ContentUnavailableView {
                    Label(title, systemImage: "film")
                } description: {
                    Text(message)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
