// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Presentation",
    defaultLocalization: "en",
    platforms: [.iOS("16.0")],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Presentation",
            targets: ["Presentation"]),
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../Infrastructure/TestUtility"),
        .package(path: "../Infrastructure/Localization"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.16.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.11.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Presentation",
            dependencies: [
                "Domain",
                "Kingfisher"
            ]
        ),
        .testTarget(
            name: "PresentationTests",
            dependencies: ["Presentation", "TestUtility", "Localization"]),
        .testTarget(
            name: "PresentationSnapshotTests",
            dependencies: [
                "Presentation",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ])
    ]
)
