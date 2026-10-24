// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ZenState",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "ZenState", targets: ["ZenState"])
    ],
    dependencies: [
        .package(path: "../ZenModel"),
        .package(path: "../ZenStore"),
    ],
    targets: [
        .target(name: "ZenState", dependencies: ["ZenModel", "ZenStore"]),
        .testTarget(name: "ZenStateTests", dependencies: ["ZenState"]),
    ]
)
