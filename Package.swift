// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "hummingbird-storage",
    platforms: [
       .macOS(.v12),
    ],
    products: [
        .library(name: "FeatherStorage", targets: ["FeatherStorage"]),
        .library(name: "FeatherFileStorage", targets: ["FeatherFileStorage"]),
        .library(name: "FeatherS3Storage", targets: ["FeatherS3Storage"]),
        
        .library(name: "HummingbirdStorage", targets: ["HummingbirdStorage"]),
        .library(name: "HummingbirdFileStorage", targets: ["HummingbirdFileStorage"]),
        .library(name: "HummingbirdS3Storage", targets: ["HummingbirdS3Storage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git",from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.48.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
        .package(url: "https://github.com/soto-project/soto-core", from: "6.5.0"),
        .package(url: "https://github.com/soto-project/soto-codegenerator", from: "0.8.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird", from: "1.5.0"),
        .package(url: "https://github.com/FeatherCMS/hummingbird-aws", branch: "main"),
        .package(url: "https://github.com/FeatherCMS/hummingbird-services", branch: "main"),
    ],
    targets: [
        .target(name: "FeatherStorage", dependencies: [
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "Logging", package: "swift-log"),
        ]),
        .target(name: "FeatherFileStorage", dependencies: [
            .target(name: "FeatherStorage"),
        ]),
        .target(name: "FeatherS3Storage", dependencies: [
            .target(name: "SotoS3"),
            .target(name: "FeatherStorage"),
        ]),
        
        .target(name: "HummingbirdStorage", dependencies: [
            .product(name: "Hummingbird", package: "hummingbird"),
            .product(name: "HummingbirdServices", package: "hummingbird-services"),
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "Logging", package: "swift-log"),
            .target(name: "FeatherStorage"),
        ]),
        .target(name: "HummingbirdFileStorage", dependencies: [
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "Logging", package: "swift-log"),
            .target(name: "HummingbirdStorage"),
            .target(name: "FeatherFileStorage"),
        ]),
        .target(name: "HummingbirdS3Storage", dependencies: [
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "Logging", package: "swift-log"),
            .product(name: "HummingbirdAWS", package: "hummingbird-aws"),
            .target(name: "HummingbirdStorage"),
            .target(name: "FeatherS3Storage"),
        ]),
        .target(
            name: "SotoS3",
            dependencies: [
                .product(name: "SotoCore", package: "soto-core"),
            ],
            plugins: [
                .plugin(
                    name: "SotoCodeGeneratorPlugin",
                    package: "soto-codegenerator"
                ),
            ]
        ),
        .testTarget(name: "HummingbirdFileStorageTests", dependencies: [
            .target(name: "HummingbirdFileStorage"),
        ]),
        .testTarget(name: "HummingbirdS3StorageTests", dependencies: [
            .target(name: "HummingbirdS3Storage"),
        ]),
        
        .testTarget(name: "FeatherFileStorageTests", dependencies: [
            .target(name: "FeatherFileStorage"),
        ]),
        .testTarget(name: "FeatherS3StorageTests", dependencies: [
            .target(name: "FeatherS3Storage"),
        ]),
    ]
)
