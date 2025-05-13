// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CreateMLAnnotator",
    dependencies: [
        .package(url: "https://github.com/tomieq/BootstrapStarter", branch: "master"),
        .package(url: "https://github.com/tomieq/swifter", from: "3.0.0"),
        .package(url: "https://github.com/tomieq/Template.swift.git", from: "1.6.0"),
        .package(url: "https://github.com/tomieq/Env", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .executableTarget(
            name: "CreateMLAnnotator",
        dependencies: [
            .product(name: "BootstrapTemplate", package: "BootstrapStarter"),
            .product(name: "Swifter", package: "Swifter"),
            .product(name: "Template", package: "Template.swift"),
            .product(name: "Env", package: "Env")
        ]),
    ]
)
