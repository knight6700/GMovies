// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DesignSystem",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
    ],
    dependencies: [
        .package(path: "../Utilities"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.16.0"),
    ],
    targets: [
        .target(
            name: "DesignSystem",
            dependencies: [
                .product(name: "Utilities", package: "Utilities"),
            ],
            path: "Sources/DesignSystem",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "DesignSystemSnapshotTests",
            dependencies: [
                "DesignSystem",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            path: "Tests/DesignSystemSnapshotTests",
            exclude: ["__Snapshots__"]
        ),
    ]
)
