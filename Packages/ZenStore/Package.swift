// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ZenStore",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "ZenStore", targets: ["ZenStore"])
    ],
    dependencies: [
        .package(path: "../ZenModel")
    ],
    targets: [
        .target(name: "ZenStore", dependencies: ["ZenModel"]),
        .testTarget(name: "ZenStoreTests", dependencies: ["ZenStore"]),
    ]
)
