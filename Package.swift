// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BLog",
    products: [
        .library(
            name: "BLog",
            targets: ["BLog"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BLog",
            dependencies: []),
        .testTarget(
            name: "BLogTests",
            dependencies: ["BLog"]),
    ]
)
