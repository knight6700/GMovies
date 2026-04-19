//  MovieDetailsRepository.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

public protocol MovieDetailsRepository: Sendable {
    func getMovieDetail(id: Int) async throws -> MovieDetail
    func refreshMovieDetail(id: Int) async throws -> MovieDetail
}
