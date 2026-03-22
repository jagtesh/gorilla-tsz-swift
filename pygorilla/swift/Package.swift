// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Pygorilla",
    products: [
        .library(name: "Pygorilla", type: .dynamic, targets: ["Pygorilla"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jagtesh/ApplePy.git", from: "0.1.0"),
        .package(path: "../../"),  // parent GorillaTSZ package
    ],
    targets: [
        .target(
            name: "Pygorilla",
            dependencies: [
                .product(name: "ApplePy", package: "ApplePy"),
                .product(name: "ApplePyClient", package: "ApplePy"),
                .product(name: "GorillaTSZ", package: "gorilla-tsz-swift"),
            ]
        ),
    ]
)
