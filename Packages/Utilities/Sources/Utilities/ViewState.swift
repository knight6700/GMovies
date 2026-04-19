//  ViewState.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

public enum ViewState: Equatable {
    case idle
    case loading
    case loaded
    case empty
    case error(String)
}
