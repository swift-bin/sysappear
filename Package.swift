// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "sysappear",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "SystemAppearance",
            targets: ["SystemAppearance"]
        ),
        .executable(
            name: "sysappear",
            targets: ["SystemAppearanceCLI"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-lco/Arguments.git",
            branch: "master"
        ),
    ],
    targets: [
        .target(
            name: "SystemAppearance"
        ),
        .executableTarget(
            name: "SystemAppearanceCLI",
            dependencies: [
                "SystemAppearance",
                .product(name: "Arguments", package: "Arguments"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
