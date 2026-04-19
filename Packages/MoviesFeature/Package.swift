// swift-tools-version: 5.9
//  Package.swift
//  GMovies — MoviesFeature (multi-target, feature-based)
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "MoviesFeature",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Movies",       targets: ["Movies"]),
        .library(name: "MovieDetails", targets: ["MovieDetails"]),
    ],
    dependencies: [
        .package(path: "../Utilities"),
        .package(path: "../Networking"),
        .package(path: "../Persistence"),
        .package(path: "../DesignSystem"),
    ],
    targets: [
        .target(
            name: "Movies",
            dependencies: [
                .product(name: "Networking", package: "Networking"),
                .product(name: "Utilities", package: "Utilities"),
                .product(name: "DesignSystem", package: "DesignSystem"),
                .product(name: "Persistence", package: "Persistence"),
            ],
            path: "Sources/Movies"
        ),
        .target(
            name: "MovieDetails",
            dependencies: [
                .product(name: "Networking", package: "Networking"),
                .product(name: "Utilities", package: "Utilities"),
                .product(name: "DesignSystem", package: "DesignSystem"),
                .product(name: "Persistence", package: "Persistence"),
            ],
            path: "Sources/MovieDetails"
        ),        
        .testTarget(
            name: "MoviesTests",
            dependencies: [
                .product(name: "Networking", package: "Networking"),
                .product(name: "Utilities", package: "Utilities"),
                .product(name: "Persistence", package: "Persistence"),
                "Movies",
            ],
            path: "Tests/MoviesTests"
        ),
        .testTarget(
            name: "MovieDetailsTests",
            dependencies: [
                .product(name: "Networking", package: "Networking"),
                .product(name: "Utilities", package: "Utilities"),
                .product(name: "Persistence", package: "Persistence"),
                "MovieDetails",
            ],
            path: "Tests/MovieDetailsTests"
        ),
    ]
)
