// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ZenModel",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "ZenModel", targets: ["ZenModel"])
    ],
    targets: [
        .target(name: "ZenModel"),
        .testTarget(name: "ZenModelTests", dependencies: ["ZenModel"]),
    ]
)
