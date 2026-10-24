// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ZenWeb",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "ZenWeb", targets: ["ZenWeb"])
    ],
    dependencies: [
        .package(path: "../ZenModel")
    ],
    targets: [
        .target(name: "ZenWeb", dependencies: ["ZenModel"])
    ]
)
