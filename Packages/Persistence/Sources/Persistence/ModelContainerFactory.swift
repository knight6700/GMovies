//  ModelContainerFactory.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import Foundation
import OSLog
import SwiftData

public enum ModelContainerFactory {
    public static func makeContainer(
        for schema: Schema,
        storeName: String,
        storeURL: URL? = nil,
        logger: Logger = Logger(subsystem: "com.gmovies.MoviesCore", category: "ModelContainerFactory")
    ) throws -> ModelContainer {
        let resolvedStoreURL = storeURL ?? defaultStoreURL(storeName: storeName)
        let configuration = ModelConfiguration(url: resolvedStoreURL)

        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            logger.error(
                """
                Opening SwiftData store failed at \(resolvedStoreURL.path, privacy: .public).
                Removing store files and retrying.
                Error: \(error.localizedDescription, privacy: .public)
                """
            )
            try removeStoreFiles(at: resolvedStoreURL)

            do {
                let container = try ModelContainer(for: schema, configurations: configuration)
                logger.notice(
                    "Recovered SwiftData store at \(resolvedStoreURL.path, privacy: .public)"
                )
                return container
            } catch {
                logger.critical(
                    """
                    SwiftData store recovery failed at \(resolvedStoreURL.path, privacy: .public).
                    Error: \(error.localizedDescription, privacy: .public)
                    """
                )
                throw error
            }
        }
    }

    static func defaultStoreURL(storeName: String) -> URL {
        let baseDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        try? FileManager.default.createDirectory(at: baseDirectory, withIntermediateDirectories: true)
        return baseDirectory.appendingPathComponent(storeName)
    }

    static func removeStoreFiles(at storeURL: URL) throws {
        let fileManager = FileManager.default
        let relatedURLs = [
            storeURL,
            storeURL.appendingPathExtension("sqlite"),
            storeURL.appendingPathExtension("sqlite-shm"),
            storeURL.appendingPathExtension("sqlite-wal"),
            storeURL.appendingPathExtension("shm"),
            storeURL.appendingPathExtension("wal")
        ]

        for url in relatedURLs where fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
}
