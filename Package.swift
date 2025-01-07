// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "peak-ios-llmkit",
    platforms: [
            .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "LLMKit",
            targets: ["LLMKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/eastriverlee/LLM.swift", branch: "pinned")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "LLMKit",
            dependencies: [
                .product(name: "LLM", package: "LLM.swift")
            ]),
        .testTarget(
            name: "LLMKitTests",
            dependencies: ["LLMKit"])
    ]
)
