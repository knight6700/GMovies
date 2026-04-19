//  FormattersTests.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Testing
@testable import Utilities

@Suite("Formatters")
struct FormattersTests {

    @Test
    func releaseDateFormatsCorrectly() {
        #expect(Formatters.releaseDate("2014-11-05") == "November 2014")
    }

    @Test
    func releaseDateReturnsInputForInvalidDate() {
        #expect(Formatters.releaseDate("not-a-date") == "not-a-date")
    }

    @Test
    func currencyFormatsWithDollarSign() {
        let result = Formatters.currency(165_000_000)
        #expect(result.contains("165"))
        #expect(result.contains("$"))
    }

    @Test
    func currencyFormatsZero() {
        let result = Formatters.currency(0)
        #expect(result.contains("0"))
    }
}
