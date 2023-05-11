# Hummingbird Storage Component

A simple [Hummingbird](https://github.com/hummingbird-project/hummingbird) storage component, which can store files via [AWS S3](https://aws.amazon.com/s3/) or a local file storage provider.

## Getting started 

Adding the dependency

Insert the following entry in your `Package.swift` file to get started:

```swift
.package(url: "https://github.com/feathercms/hummingbird-storage", from: "1.0.0"),
```

Add the `HummingbirdStorage` libarry as a dependency to your target:

```swift
.product(name: "HummingbirdStorage", package: "hummingbird-storage"),
```

Add the selected storage provider library to your target:

```swift
// local file storage provider
.product(name: "HummingbirdFileStorage", package: "hummingbird-storage"),

// S3 storage provider
.product(name: "HummingbirdS3Storage", package: "hummingbird-storage"),
```    

## HummingbirdS3

S3 storage example:

```swift
import Hummingbird
import HummingbirdAWS
import HummingbirdStorage
import HummingbirdS3Storage

let env = ProcessInfo.processInfo.environment
var logger = Logger(label: "aws-logger")
logger.logLevel = .info

let app = HBApplication()
app.services.aws = .init(
    credentialProvider: .static(
        accessKeyId: env["S3_ID"]!,
        secretAccessKey: env["S3_SECRET"]!
    ),
    options: .init(
        requestLogLevel: .info,
        errorLogLevel: .info
    ),
    httpClientProvider: .createNewWithEventLoopGroup(
        app.eventLoopGroup
    ),
    logger: logger
)

app.services.setUpS3Storage(
    using: app.services.aws,
    region: env["S3_REGION"]!,
    bucket: env["S3_BUCKET"]!
)

// usage
try await app.storage.upload(
    key: "lorem/ipsum",
    buffer: .init(string: "lorem ipsum dolor sit amet")
)
```

## HummingbirdFileStorage

Local storage example:

```swift
import Hummingbird
import HummingbirdStorage
import HummingbirdFileStorage

let app = HBApplication()
app.services.setUpFileStorage(
    workDir: "/tmp/",
    threadPool: app.threadPool
)

// usage
try await app.storage.upload(
    key: "lorem/ipsum",
    buffer: .init(string: "lorem ipsum dolor sit amet")
)
```
