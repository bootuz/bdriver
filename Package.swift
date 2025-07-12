// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Ariadne",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Ariadne",
            targets: ["Ariadne"]),
    ],
    dependencies: [
        .package(url: "https://github.com/thebrowsercompany/swift-webdriver", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Ariadne",
            dependencies: [
                .product(name: "WebDriver", package: "swift-webdriver")
            ],
            path: "Sources/Ariadne"
        ),
        .testTarget(
            name: "AriadneTests",
            dependencies: ["Ariadne"]
        ),
        .testTarget(
            name: "UITests",
            dependencies: [
                .product(name: "WebDriver", package: "swift-webdriver"),
            ],
            path: "Tests/UITests"
        )
    ]
)
