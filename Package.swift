// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "hummingbird-storage",
    platforms: [
       .macOS(.v10_15),
    ],
    products: [
        .library(name: "HummingbirdStorage", targets: ["HummingbirdStorage"]),
        .library(name: "LocalDriver", targets: ["LocalDriver"]),
        .library(name: "S3Driver", targets: ["S3Driver"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git",from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.48.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
        .package(url: "https://github.com/soto-project/soto-core.git", from: "6.5.0"),
        .package(url: "https://github.com/soto-project/soto.git", from: "6.6.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "1.4.0"),
        .package(url: "https://github.com/FeatherCMS/hummingbird-aws.git", branch: "main"),
    ],
    targets: [
        .target(name: "HummingbirdStorage", dependencies: [
            .product(name: "Hummingbird", package: "hummingbird"),
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "Logging", package: "swift-log"),
        ]),
        .target(name: "LocalDriver", dependencies: [
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "Logging", package: "swift-log"),
            .target(name: "HummingbirdStorage"),
        ]),
        .target(name: "S3Driver", dependencies: [
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "Logging", package: "swift-log"),
            .product(name: "SotoS3", package: "soto"),
            .target(name: "HummingbirdStorage"),
        ]),
        .testTarget(name: "LocalDriverTests",
             dependencies: [
                .target(name: "HummingbirdStorage"),
                .target(name: "LocalDriver"),
                .product(name: "HummingbirdFoundation", package: "hummingbird"),
        ]),
        .testTarget(name: "S3DriverTests",
             dependencies: [
                .target(name: "HummingbirdStorage"),
                .target(name: "S3Driver"),
        ]),
    ]
)
