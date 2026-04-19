//  Formatters.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation

public enum Formatters {

    private static let releaseDateInput: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    private static let releaseDateOutput: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        formatter.positiveFormat = "###0 ¤"
        return formatter
    }()

    public static func releaseDate(_ dateString: String) -> String {
        guard let date = releaseDateInput.date(from: dateString) else { return dateString }
        return releaseDateOutput.string(from: date)
    }

    public static func currency(_ amount: Int) -> String {
        currencyFormatter.string(from: NSNumber(value: amount)) ?? "\(amount) $"
    }
}
