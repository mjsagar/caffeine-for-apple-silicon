// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Caffeine",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(
            name: "Caffeine",
            targets: ["Caffeine"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "Caffeine",
            dependencies: [],
            path: "Sources/Caffeine"
        ),
        .testTarget(
            name: "CaffeineTests",
            dependencies: [],
            path: "Tests"
        )
    ]
)
