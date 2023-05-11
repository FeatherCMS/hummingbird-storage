// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "hummingbird-storage",
    platforms: [
       .macOS(.v12),
    ],
    products: [
        .library(name: "HummingbirdStorage", targets: ["HummingbirdStorage"]),
        .library(name: "HummingbirdFileStorage", targets: ["HummingbirdFileStorage"]),
        .library(name: "HummingbirdS3Storage", targets: ["HummingbirdS3Storage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird", from: "1.5.0"),
        .package(url: "https://github.com/FeatherCMS/hummingbird-aws", branch: "main"),
        .package(url: "https://github.com/FeatherCMS/hummingbird-services", branch: "main"),
        .package(url: "https://github.com/FeatherCMS/feather-storage", branch: "main"),
    ],
    targets: [
        .target(name: "HummingbirdStorage", dependencies: [
            .product(name: "Hummingbird", package: "hummingbird"),
            .product(name: "HummingbirdServices", package: "hummingbird-services"),
            .product(name: "FeatherStorage", package: "feather-storage"),
        ]),
        .target(name: "HummingbirdFileStorage", dependencies: [
            .product(name: "FeatherFileStorage", package: "feather-storage"),
            .target(name: "HummingbirdStorage"),
        ]),
        .target(name: "HummingbirdS3Storage", dependencies: [
            .product(name: "HummingbirdAWS", package: "hummingbird-aws"),
            .product(name: "FeatherS3Storage", package: "feather-storage"),
            .target(name: "HummingbirdStorage"),
        ]),
        .testTarget(name: "HummingbirdFileStorageTests", dependencies: [
            .target(name: "HummingbirdFileStorage"),
        ]),
        .testTarget(name: "HummingbirdS3StorageTests", dependencies: [
            .target(name: "HummingbirdS3Storage"),
        ]),
    ]
)
