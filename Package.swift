// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LetterMatter",
    products: [
        .library(
            name: "LetterMatter",
            targets: ["LetterMatter"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LetterMatter",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "LetterMatterTests",
            dependencies: ["LetterMatter"],
            path: "Tests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
