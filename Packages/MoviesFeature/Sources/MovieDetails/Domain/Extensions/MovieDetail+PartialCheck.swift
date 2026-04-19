//  MovieDetail+PartialCheck.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

public extension MovieDetail {
     var isPartialOfflineData: Bool {
        status.isEmpty && budget == 0 && revenue == 0 && runtime == nil && spokenLanguages.isEmpty
    }
}
