//  GenreChipView.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import SwiftUI

public struct GenreChipView: View {

    let name: String
    let isSelected: Bool
    let onTap: () -> Void

    public init(name: String, isSelected: Bool, onTap: @escaping () -> Void) {
        self.name = name
        self.isSelected = isSelected
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            Text(name)
                .font(DSFont.chipLabel)
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.xs)
                .foregroundStyle(isSelected ? DSColor.background : DSColor.accent)
                .background(
                    Capsule().fill(isSelected ? DSColor.accent : Color.clear)
                )
                .overlay(
                    Capsule().stroke(DSColor.accent, lineWidth: DSSizing.chipBorderWidth)
                )
        }
        .buttonStyle(.plain)
    }
}
