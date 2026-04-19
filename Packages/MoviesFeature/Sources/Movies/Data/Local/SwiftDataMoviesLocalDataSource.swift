//  SwiftDataMoviesLocalDataSource.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import OSLog
import Persistence
import SwiftData
import Utilities


public actor SwiftDataMoviesLocalDataSource: MoviesLocalDataSource {

    private let container: ModelContainer
    private static let storeName = "MoviesCache.store"

    public init(container: ModelContainer) {
        self.container = container
    }

    /// Creates the SwiftData container for movies and genres.
    public static func makeContainer() throws -> ModelContainer {
        try makeContainer(storeURL: nil)
    }

    static func makeContainer(storeURL: URL?) throws -> ModelContainer {
        let schema = Schema([CachedMovie.self, CachedMoviesPage.self, CachedGenre.self])
        return try ModelContainerFactory.makeContainer(
            for: schema,
            storeName: storeName,
            storeURL: storeURL
        )
    }

    public func saveMovies(_ movies: [Movie], page: Int, totalPages: Int) async throws {
        let context = ModelContext(container)
        let timestamp = Date()
        let incomingMovieIDs = movies.map(\.id)
        let existingMovies = try Self.fetchMovies(withIDs: incomingMovieIDs, using: context)
        let moviesByID = Dictionary(uniqueKeysWithValues: existingMovies.map { ($0.id, $0) })

        for movie in movies {
            if let cached = moviesByID[movie.id] {
                CachedMovieMapper.update(cached, from: movie)
            } else {
                context.insert(CachedMovieMapper.map(movie))
            }
        }

        let pageValue = page
        let pageDescriptor = FetchDescriptor<CachedMoviesPage>(
            predicate: #Predicate { $0.page == pageValue }
        )
        let previousPageMovieIDs: [Int]
        if let existingPage = try context.fetch(pageDescriptor).first {
            previousPageMovieIDs = existingPage.movieIDs
            existingPage.movieIDs = movies.map(\.id)
            existingPage.totalPages = totalPages
            existingPage.cachedAt = timestamp
        } else {
            previousPageMovieIDs = []
            context.insert(
                CachedMoviesPage(
                    page: page,
                    movieIDs: movies.map(\.id),
                    totalPages: totalPages,
                    cachedAt: timestamp
                )
            )
        }

        try Self.deleteOrphanedMovies(
            previousPageMovieIDs: previousPageMovieIDs,
            using: context
        )

        do {
            try context.save()
        } catch {
            Logger.moviesStore.error("saveMovies failed: \(error)")
            throw error
        }
    }

    public func loadMovies(page: Int) async throws -> LocalSnapshot<PaginatedResult<Movie>> {
        let context = ModelContext(container)
        let pageValue = page
        let pageDescriptor = FetchDescriptor<CachedMoviesPage>(
            predicate: #Predicate { $0.page == pageValue }
        )

        guard let cachedPage = try context.fetch(pageDescriptor).first else {
            let empty = PaginatedResult<Movie>(items: [], page: page, totalPages: 1)
            return LocalSnapshot(value: empty, cachedAt: .distantPast)
        }

        let cachedMovies = try Self.fetchMovies(withIDs: cachedPage.movieIDs, using: context)
        let moviesByID = Dictionary(uniqueKeysWithValues: cachedMovies.map { ($0.id, CachedMovieMapper.map($0)) })
        let items = cachedPage.movieIDs.compactMap { moviesByID[$0] }
        let value = PaginatedResult(items: items, page: page, totalPages: cachedPage.totalPages)
        return LocalSnapshot(value: value, cachedAt: cachedPage.cachedAt)
    }

    public func saveGenres(_ genres: [Genre]) async throws {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<CachedGenre>()
        let existing = try context.fetch(descriptor)
        existing.forEach { context.delete($0) }
        genres.forEach { context.insert(CachedGenreMapper.map($0)) }
        do {
            try context.save()
        } catch {
            Logger.moviesStore.error("saveGenres failed: \(error)")
            throw error
        }
    }

    public func loadGenres() async throws -> LocalSnapshot<[Genre]> {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<CachedGenre>(sortBy: [SortDescriptor(\.name)])
        let cached = try context.fetch(descriptor)
        let value = cached.map(CachedGenreMapper.map)
        let cachedAt = cached.map(\.cachedAt).max() ?? .distantPast
        return LocalSnapshot(value: value, cachedAt: cachedAt)
    }
}

private extension SwiftDataMoviesLocalDataSource {
    static func fetchMovies(withIDs ids: [Int], using context: ModelContext) throws -> [CachedMovie] {
        guard !ids.isEmpty else { return [] }
        let ids = ids
        let descriptor = FetchDescriptor<CachedMovie>(
            predicate: #Predicate { ids.contains($0.id) }
        )
        return try context.fetch(descriptor)
    }

    static func deleteOrphanedMovies(
        previousPageMovieIDs: [Int],
        using context: ModelContext
    ) throws {
        guard !previousPageMovieIDs.isEmpty else { return }
        let allPages = try context.fetch(FetchDescriptor<CachedMoviesPage>())
        let referencedMovieIDs = Set(allPages.flatMap(\.movieIDs))
        let orphanedMovieIDs = previousPageMovieIDs.filter { !referencedMovieIDs.contains($0) }
        guard !orphanedMovieIDs.isEmpty else { return }

        let orphanedMovies = try fetchMovies(withIDs: orphanedMovieIDs, using: context)
        orphanedMovies.forEach { context.delete($0) }
    }
}
