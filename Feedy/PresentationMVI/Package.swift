// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PresentationMVI",
    defaultLocalization: "en",
    platforms: [.iOS("17.0")],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PresentationMVI",
            targets: ["PresentationMVI"]),
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../CommonUI"),
        .package(path: "../Infrastructure/TestUtility"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.16.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.11.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PresentationMVI",
            dependencies: [
                "Domain",
                "CommonUI",
                "Kingfisher"
            ]
        ),
        .testTarget(
            name: "PresentationMVITests",
            dependencies: ["PresentationMVI", "CommonUI", "TestUtility"]),
        .testTarget(
            name: "PresentationMVISnapshotTests",
            dependencies: [
                "PresentationMVI",
                "CommonUI",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ])
    ]
)
