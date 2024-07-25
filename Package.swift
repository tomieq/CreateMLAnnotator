// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CreateMLAnnotator",
    dependencies: [
        .package(url: "https://github.com/tomieq/swifter.git", .upToNextMajor(from: "1.5.6")),
        .package(url: "https://github.com/tomieq/Template.swift.git", .upToNextMajor(from: "1.1.0"))
    ],
    targets: [
        .executableTarget(
            name: "CreateMLAnnotator",
        dependencies: [
            .product(name: "Swifter", package: "Swifter"),
            .product(name: "Template", package: "Template.swift")
        ]),
    ]
)
