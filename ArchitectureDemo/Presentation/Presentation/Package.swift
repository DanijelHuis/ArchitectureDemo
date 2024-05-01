// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Presentation",
    platforms: [.iOS("16.0")],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Presentation",
            targets: ["Presentation"]),
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../Uniflow")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Presentation",
            dependencies: ["Domain", "Uniflow"]),
        .testTarget(
            name: "PresentationTests",
            dependencies: ["Presentation"]),
    ]
)
