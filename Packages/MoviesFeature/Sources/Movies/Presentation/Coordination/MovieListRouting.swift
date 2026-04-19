//  MovieListRouting.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

@MainActor
public protocol MovieListRouting: AnyObject {
    func goToMovieDetails(id: Int, preview: MovieDetailPreviewData?)
}
