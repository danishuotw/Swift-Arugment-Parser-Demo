// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DemoMyTools",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.0"),
        .package(url: "https://github.com/apple/swift-tools-support-core.git", from: "0.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DemoMyTools",
            dependencies: [.product(name: "ArgumentParser", package:"swift-argument-parser"),
                           .product(name: "SwiftToolsSupport",package: "swift-tools-support-core")]),
        .testTarget(
            name: "DemoMyToolsTests",
            dependencies: ["DemoMyTools"]),
    ]
)