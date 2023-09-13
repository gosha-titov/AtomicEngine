// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TypoHunt",
    products: [
        .library(
            name: "TypoHunt",
            targets: ["TypoHunt"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TypoHunt",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "TypoHuntTests",
            dependencies: ["TypoHunt"],
            path: "Tests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
