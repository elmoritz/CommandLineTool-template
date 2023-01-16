// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "swift-cli",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git",
                 from: "1.0.2")
    ],
    targets: [
        .executableTarget(
            name: "CLI-Template",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
    ]
)
