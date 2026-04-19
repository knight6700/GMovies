//  SwiftDataMovieDetailsLocalDataSource.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import OSLog
import Persistence
import SwiftData
import Utilities


public actor SwiftDataMovieDetailsLocalDataSource: MovieDetailsLocalDataSource {

    private let container: ModelContainer
    private static let storeName = "MovieDetailsCache.store"

    public init(container: ModelContainer) {
        self.container = container
    }

    /// Creates the SwiftData container for movie details.
    public static func makeContainer() throws -> ModelContainer {
        try makeContainer(storeURL: nil)
    }

    static func makeContainer(storeURL: URL?) throws -> ModelContainer {
        let schema = Schema([CachedMovieDetail.self])
        return try ModelContainerFactory.makeContainer(
            for: schema,
            storeName: storeName,
            storeURL: storeURL
        )
    }

    public func saveMovieDetail(_ detail: MovieDetail) async throws {
        let context = ModelContext(container)
        let idValue = detail.id
        let descriptor = FetchDescriptor<CachedMovieDetail>(
            predicate: #Predicate { $0.id == idValue }
        )
        let existing = try context.fetch(descriptor)
        existing.forEach { context.delete($0) }
        context.insert(CachedMovieDetailMapper.map(detail))
        do {
            try context.save()
        } catch {
            Logger.movieDetailsStore.error("saveMovieDetail failed: \(error)")
            throw error
        }
    }

    public func loadMovieDetail(id: Int) async throws -> LocalSnapshot<MovieDetail?> {
        let context = ModelContext(container)
        let idValue = id
        let descriptor = FetchDescriptor<CachedMovieDetail>(
            predicate: #Predicate { $0.id == idValue }
        )
        let cached = try context.fetch(descriptor).first
        return LocalSnapshot(
            value: cached.map(CachedMovieDetailMapper.map),
            cachedAt: cached?.cachedAt ?? .distantPast
        )
    }
}
