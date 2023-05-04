// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "hummingbird-storage",
    platforms: [
       .macOS(.v12),
    ],
    products: [
        .library(name: "HummingbirdStorage", targets: ["HummingbirdStorage"]),
//        .library(name: "HummingbirdLFS", targets: ["HummingbirdLFS"]),
        .library(name: "HummingbirdS3", targets: ["HummingbirdS3"]),
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
//        .target(name: "CRC32"),
        .target(name: "HummingbirdStorage", dependencies: [
            .product(name: "Hummingbird", package: "hummingbird"),
            .product(name: "HummingbirdServices", package: "hummingbird-services"),
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "Logging", package: "swift-log"),
        ]),
//        .target(name: "HummingbirdLFS", dependencies: [
//            .product(name: "NIO", package: "swift-nio"),
//            .product(name: "Logging", package: "swift-log"),
//            .target(name: "HummingbirdStorage"),
//            .target(name: "CRC32"),
//        ]),
        .target(name: "HummingbirdS3", dependencies: [
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "Logging", package: "swift-log"),
            .product(name: "HummingbirdAWS", package: "hummingbird-aws"),
            .target(name: "HummingbirdStorage"),
            .target(name: "SotoS3"),
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
//        .testTarget(name: "HummingbirdLFSTests",
//             dependencies: [
//                .target(name: "HummingbirdStorage"),
//                .target(name: "HummingbirdLFS"),
//                .product(name: "HummingbirdFoundation", package: "hummingbird"),
//        ]),
        .testTarget(name: "HummingbirdS3Tests", dependencies: [
            .target(name: "HummingbirdS3"),
        ]),
    ]
)
