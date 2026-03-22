// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "GorillaTSZ",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "GorillaTSZ", targets: ["GorillaTSZ"]),
    ],
    targets: [
        .target(
            name: "GorillaTSZ",
            dependencies: []
        ),
        .testTarget(
            name: "GorillaTSZTests",
            dependencies: ["GorillaTSZ"]
        ),
    ]
)
