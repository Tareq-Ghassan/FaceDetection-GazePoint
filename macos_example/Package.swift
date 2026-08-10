// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "GazePointExample",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(path: "../macos")
    ],
    targets: [
        .executableTarget(
            name: "GazePointExample",
            dependencies: [
                .product(name: "GazePointSDK", package: "macos")
            ],
            path: "."
        )
    ]
)
