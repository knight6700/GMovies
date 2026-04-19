//  DesignSystemSnapshotTests.swift
//  GMoviesTests
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import XCTest
import SwiftUI
import SnapshotTesting
import DesignSystem

// MARK: - Snapshot Helpers

private let snapshotPrecision: Float = 0.80
private let snapshotPerceptualPrecision: Float = 0.80

private extension SwiftUI.View {
    func darkMode() -> some View {
        self.environment(\.colorScheme, .dark)
    }

    func accessibilityXL() -> some View {
        self.environment(\.sizeCategory, .accessibilityExtraLarge)
    }
}

private func assertImageSnapshot(
    of view: some View,
    layout: SwiftUISnapshotLayout,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line
) {
    assertSnapshot(
        of: view,
        as: .image(
            precision: snapshotPrecision,
            perceptualPrecision: snapshotPerceptualPrecision,
            layout: layout
        ),
        file: file,
        testName: testName,
        line: line
    )
}

// MARK: - GenreChipView

final class GenreChipViewSnapshotTests: XCTestCase {

    func test_unselected() {
        let view = GenreChipView(name: "Action", isSelected: false, onTap: {})
        assertImageSnapshot(of: view, layout: .sizeThatFits)
    }

    func test_selected() {
        let view = GenreChipView(name: "Action", isSelected: true, onTap: {})
        assertImageSnapshot(of: view, layout: .sizeThatFits)
    }

    func test_longName() {
        let view = GenreChipView(name: "Science Fiction", isSelected: false, onTap: {})
        assertImageSnapshot(of: view, layout: .sizeThatFits)
    }

    func test_unselected_darkMode() {
        let view = GenreChipView(name: "Action", isSelected: false, onTap: {}).darkMode()
        assertImageSnapshot(of: view, layout: .sizeThatFits)
    }

    func test_selected_darkMode() {
        let view = GenreChipView(name: "Action", isSelected: true, onTap: {}).darkMode()
        assertImageSnapshot(of: view, layout: .sizeThatFits)
    }

    func test_selected_accessibilityXL() {
        let view = GenreChipView(name: "Action", isSelected: true, onTap: {}).accessibilityXL()
        assertImageSnapshot(of: view, layout: .sizeThatFits)
    }
}

// MARK: - OfflineBannerView

final class OfflineBannerViewSnapshotTests: XCTestCase {

    func test_appearance() {
        let view = OfflineBannerView()
        assertImageSnapshot(of: view, layout: .fixed(width: 390, height: 44))
    }

    func test_appearance_darkMode() {
        let view = OfflineBannerView().darkMode()
        assertImageSnapshot(of: view, layout: .fixed(width: 390, height: 44))
    }
}

// MARK: - SearchBarView

final class SearchBarViewSnapshotTests: XCTestCase {

    func test_empty() {
        let view = SearchBarView(text: .constant(""))
        assertImageSnapshot(of: view, layout: .fixed(width: 358, height: 52))
    }

    func test_withText() {
        let view = SearchBarView(text: .constant("Inception"))
        assertImageSnapshot(of: view, layout: .fixed(width: 358, height: 52))
    }

    func test_empty_darkMode() {
        let view = SearchBarView(text: .constant("")).darkMode()
        assertImageSnapshot(of: view, layout: .fixed(width: 358, height: 52))
    }

    func test_withText_darkMode() {
        let view = SearchBarView(text: .constant("Inception")).darkMode()
        assertImageSnapshot(of: view, layout: .fixed(width: 358, height: 52))
    }
}

// MARK: - MovieCardView

final class MovieCardViewSnapshotTests: XCTestCase {

    func test_withYearAndRating() {
        let view = MovieCardView(
            title: "Inception",
            posterURL: nil,
            rating: 8.8,
            year: 2010
        )
        assertImageSnapshot(of: view, layout: .fixed(width: 160, height: 280))
    }

    func test_withoutYear() {
        let view = MovieCardView(
            title: "Inception",
            posterURL: nil,
            rating: 8.8
        )
        assertImageSnapshot(of: view, layout: .fixed(width: 160, height: 260))
    }

    func test_longTitle() {
        let view = MovieCardView(
            title: "The Lord of the Rings: The Return of the King",
            posterURL: nil,
            rating: 9.0,
            year: 2003
        )
        assertImageSnapshot(of: view, layout: .fixed(width: 160, height: 300))
    }

    func test_lowRating() {
        let view = MovieCardView(
            title: "Bad Movie",
            posterURL: nil,
            rating: 3.2,
            year: 2022
        )
        assertImageSnapshot(of: view, layout: .fixed(width: 160, height: 280))
    }

    func test_withYearAndRating_darkMode() {
        let view = MovieCardView(
            title: "Inception",
            posterURL: nil,
            rating: 8.8,
            year: 2010
        ).darkMode()
        assertImageSnapshot(of: view, layout: .fixed(width: 160, height: 280))
    }

    func test_withYearAndRating_accessibilityXL() {
        let view = MovieCardView(
            title: "Inception",
            posterURL: nil,
            rating: 8.8,
            year: 2010
        ).accessibilityXL()
        assertImageSnapshot(of: view, layout: .fixed(width: 180, height: 340))
    }

    func test_zeroRating() {
        let view = MovieCardView(
            title: "Unrated Film",
            posterURL: nil,
            rating: 0.0,
            year: 2024
        )
        assertImageSnapshot(of: view, layout: .fixed(width: 160, height: 280))
    }

    func test_perfectRating() {
        let view = MovieCardView(
            title: "Perfect Movie",
            posterURL: nil,
            rating: 10.0,
            year: 2024
        )
        assertImageSnapshot(of: view, layout: .fixed(width: 160, height: 280))
    }
}

// MARK: - DSContentUnavailableView

final class DSContentUnavailableViewSnapshotTests: XCTestCase {

    func test_errorStyle() {
        let view = DSContentUnavailableView(
            style: .error(message: "Could not load movies. Check your connection.", retry: {})
        )
        assertImageSnapshot(of: view, layout: .fixed(width: 390, height: 420))
    }

    func test_emptyStyle() {
        let view = DSContentUnavailableView(
            style: .empty(title: "No Movies Found", message: "Try a different search term.")
        )
        assertImageSnapshot(of: view, layout: .fixed(width: 390, height: 420))
    }

    func test_errorStyle_darkMode() {
        let view = DSContentUnavailableView(
            style: .error(message: "Could not load movies. Check your connection.", retry: {})
        ).darkMode()
        assertImageSnapshot(of: view, layout: .fixed(width: 390, height: 420))
    }

    func test_emptyStyle_darkMode() {
        let view = DSContentUnavailableView(
            style: .empty(title: "No Movies Found", message: "Try a different search term.")
        ).darkMode()
        assertImageSnapshot(of: view, layout: .fixed(width: 390, height: 420))
    }

    func test_errorStyle_accessibilityXL() {
        let view = DSContentUnavailableView(
            style: .error(message: "Could not load movies. Check your connection.", retry: {})
        ).accessibilityXL()
        assertImageSnapshot(of: view, layout: .fixed(width: 390, height: 520))
    }
}
