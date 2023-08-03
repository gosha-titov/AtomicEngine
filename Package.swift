// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AtomicEngine",
    products: [
        .library(
            name: "AtomicEngine",
            targets: ["AtomicEngine"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AtomicEngine",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "AtomicEngineTests",
            dependencies: ["AtomicEngine"]),
    ],
    swiftLanguageVersions: [.v5]
)
