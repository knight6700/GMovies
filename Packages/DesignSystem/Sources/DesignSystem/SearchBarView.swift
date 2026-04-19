//  SearchBarView.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import SwiftUI

public struct SearchBarView: View {

    @Binding var text: String

    public init(text: Binding<String>) {
        _text = text
    }

    public var body: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search movies...", text: $text)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(DSSpacing.inputPadding)
        .background(DSColor.inputSurface)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
    }
}
