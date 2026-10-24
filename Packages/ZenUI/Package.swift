// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ZenUI",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "ZenUI", targets: ["ZenUI"])
    ],
    dependencies: [
        .package(path: "../ZenModel"),
        .package(path: "../ZenState"),
    ],
    targets: [
        .target(name: "ZenUI", dependencies: ["ZenModel", "ZenState"])
    ]
)
