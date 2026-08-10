// swift-tools-version:6.3
import PackageDescription

let package = Package(
    name: "GazePointSDK",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "GazePointSDK",
            targets: ["GazePointSDK"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GazePointSDK",
            dependencies: [],
            path: "Sources/GazePointSDK"
        ),
        .testTarget(
            name: "GazePointSDKTests",
            dependencies: ["GazePointSDK"],
            path: "Tests/GazePointSDKTests"
        ),
    ]
)
