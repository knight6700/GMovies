//  AppCoordinator.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import SwiftUI

@MainActor
@Observable
final class AppCoordinator {

    let moviesCoordinator: MoviesFlowCoordinator

    init(moviesCoordinator: MoviesFlowCoordinator) {
        self.moviesCoordinator = moviesCoordinator
    }
}
