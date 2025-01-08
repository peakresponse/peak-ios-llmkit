// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LLMKit",
    platforms: [
            .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "LLMKit",
            targets: ["LLMKit", "LLMKitAWSBedrock", "LLMKitLlama"])
    ],
    dependencies: [
        .package(url: "https://github.com/eastriverlee/LLM.swift", branch: "pinned"),
        .package(url: "https://github.com/awslabs/aws-sdk-swift", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "LLMKit",
            dependencies: [
                .product(name: "LLM", package: "LLM.swift")
            ]),
        .target(
            name: "LLMKitAWSBedrock",
            dependencies: [
                "LLMKit",
                .product(name: "AWSBedrockRuntime", package: "aws-sdk-swift")
            ]),
        .target(
            name: "LLMKitLlama",
            dependencies: [
                "LLMKit",
                .product(name: "LLM", package: "LLM.swift")
            ]),
        .testTarget(
            name: "LLMKitTests",
            dependencies: ["LLMKit", "LLMKitAWSBedrock", "LLMKitLlama"])
    ]
)
