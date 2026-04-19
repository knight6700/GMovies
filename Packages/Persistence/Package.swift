// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Persistence",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Persistence", targets: ["Persistence"]),
    ],
    dependencies: [
        .package(path: "../Utilities"),
    ],
    targets: [
        .target(
            name: "Persistence",
            dependencies: [
                .product(name: "Utilities", package: "Utilities"),
            ],
            path: "Sources/Persistence"
        ),
        .testTarget(
            name: "PersistenceTests",
            dependencies: ["Persistence"],
            path: "Tests/PersistenceTests"
        ),
    ]
)
