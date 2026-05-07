// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LLMKit",
    platforms: [
        .macOS(.v14),
        .iOS(.v15),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "LLMKit", targets: ["LLMKit"]),
        .library(name: "LLMKitAWSBedrock", targets: ["LLMKitAWSBedrock"]),
    ],
    dependencies: [
        .package(url: "https://github.com/awslabs/aws-sdk-swift", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "LLMKit"),
        .target(
            name: "LLMKitAWSBedrock",
            dependencies: [
                "LLMKit",
                .product(name: "AWSBedrockRuntime", package: "aws-sdk-swift")
            ]),
        .testTarget(
            name: "LLMKitTests",
            dependencies: ["LLMKit", "LLMKitAWSBedrock"])
    ]
)
