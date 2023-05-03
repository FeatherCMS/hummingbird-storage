import XCTest
import Logging
import NIO
import Hummingbird
import HummingbirdAWS
import HummingbirdStorage
@testable import HummingbirdS3

final class HummingbirdS3Tests: XCTestCase {

    
    func testUpload() async throws {
        let env = ProcessInfo.processInfo.environment
        
        var logger = Logger(label: "aws-logger")
        logger.logLevel = .info
        
        let app = HBApplication()
        app.aws.client = .init(
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
        
        app.file.storage = HBS3StorageService(
            client: app.aws.client,
            region: .eucentral1,
            bucket: .init(name: "bbtestbucket01")
        )
        
        let storage = app.file.storage.make(logger: logger, eventLoop: app.eventLoopGroup.next())
        
        try await storage.create(key: "foo")
            

        try app.shutdownApplication()
    }
    
//    func testUpload() async throws {
//        let key = "test-01.txt"
//        let contents = "lorem ipsum dolor sit amet"
//
//        try await os.upload(
//            key: key,
//            buffer: .init(string: contents),
//            checksum: nil,
//            timeout: .seconds(30)
//        )
//
//        let buffer = try await os.download(
//            key: key,
//            range: nil,
//            timeout: .seconds(30)
//        )
//
//        guard let res = buffer.utf8String else {
//            return XCTFail("Invalid byte buffer response data value.")
//        }
//        XCTAssertEqual(res, contents)
//    }
//
//    func testUploadStream() async throws {
//        let key = "test-02.txt"
//        let contents = "lorem ipsum dolor sit amet"
//
//        let stream: AsyncThrowingStream<ByteBuffer, Error> = .init { c in
//            c.yield(.init(string: contents))
//            c.finish()
//        }
//
//        try await os.upload(
//            sequence: stream,
//            size: UInt(contents.count),
//            key: key,
//            checksum: nil,
//            timeout: .seconds(30)
//        )
//
//        let buffer = try await os.download(
//            key: key,
//            range: nil,
//            timeout: .seconds(30)
//        )
//
//        guard let res = buffer.utf8String else {
//            return XCTFail("Invalid byte buffer response data value.")
//        }
//        XCTAssertEqual(res, contents)
//    }
//
//    func testUploadValidChecksum() async throws {
//        let key = "test-03.txt"
//        let contents = "lorem ipsum dolor sit amet"
//        let data = Data(contents.utf8)
//
//        let calculator = os.createChecksumCalculator()
//        calculator.update(.init(data))
//        let checksum = calculator.finalize()
//
//        try await os.upload(
//            key: key,
//            buffer: .init(data: data),
//            checksum: checksum,
//            timeout: .seconds(30)
//        )
//    }
//
//    func testUploadInvalidChecksum() async throws {
//        let key = "test-04.txt"
//        let contents = "lorem ipsum dolor sit amet"
//        let data = Data(contents.utf8)
//
//        do {
//            try await os.upload(
//                key: key,
//                buffer: .init(data: data),
//                checksum: "invalid",
//                timeout: .seconds(30)
//            )
//            XCTFail("Should fail with invalid checksum error.")
//        }
//        catch ObjectStorageError.invalidChecksum {
//            // we're good
//        }
//    }
//
//    func testCreate() async throws {
//        let key = "dir01/dir02/dir03"
//        try await os.create(key: key)
//
//        let list1 = try await os.list(key: "dir01")
//        XCTAssertEqual(list1, ["dir02"])
//
//        let list2 = try await os.list(key: "dir01/dir02")
//        XCTAssertEqual(list2, ["dir03"])
//    }
//
//    func testList() async throws {
//        let key1 = "dir02/dir03"
//        try await os.create(key: key1)
//
//        let key2 = "dir02/test-01.txt"
//        try await os.upload(
//            key: key2,
//            buffer: .init(string: "test"),
//            checksum: nil,
//            timeout: .seconds(30)
//        )
//
//        let res = try await os.list(key: "dir02")
//        XCTAssertEqual(res, ["dir03", "test-01.txt"])
//    }
//
//    func testExists() async throws {
//        let key1 = "non-existing-thing"
//        let exists1 = await os.exists(key: key1)
//        XCTAssertFalse(exists1)
//
//        let key2 = "my/dir"
//        try await os.create(key: key2)
//        let exists2 = await os.exists(key: key2)
//        XCTAssertTrue(exists2)
//    }
//
//    func testListFile() async throws {
//        let key = "dir04/test-01.txt"
//        try await os.upload(
//            key: key,
//            buffer: .init(string: "test"),
//            checksum: nil,
//            timeout: .seconds(30)
//        )
//
//        let res = try await os.list(key: key)
//        XCTAssertEqual(res, [])
//    }
//
//    func testCopy() async throws {
//        let key = "test-02.txt"
//        try await os.upload(
//            key: key,
//            buffer: .init(string: "lorem ipsum"),
//            checksum: nil,
//            timeout: .seconds(30)
//        )
//
//        let dest = "test-03.txt"
//        try await os.copy(key: key, to: dest)
//
//        let res1 = await os.exists(key: key)
//        XCTAssertTrue(res1)
//
//        let res2 = await os.exists(key: dest)
//        XCTAssertTrue(res2)
//    }
//
//    func testMove() async throws {
//        let key = "test-04.txt"
//        try await os.upload(
//            key: key,
//            buffer: .init(string: "dolor sit amet"),
//            checksum: nil,
//            timeout: .seconds(30)
//        )
//
//        let dest = "test-05.txt"
//        try await os.move(key: key, to: dest)
//
//        let res1 = await os.exists(key: key)
//        XCTAssertFalse(res1)
//
//        let res2 = await os.exists(key: dest)
//        XCTAssertTrue(res2)
//    }
//
//    func testDownload() async throws {
//        let key = "test-04.txt"
//        let contents = "lorem ipsum dolor sit amet"
//
//        try await os.upload(
//            key: key,
//            buffer: .init(string: contents),
//            checksum: nil,
//            timeout: .seconds(30)
//        )
//
//        let buffer = try await os.download(
//            key: key,
//            range: nil,
//            timeout: .seconds(30)
//        )
//        guard let res = buffer.utf8String else {
//            return XCTFail("Invalid byte buffer response data value.")
//        }
//        XCTAssertEqual(res, contents)
//    }
//
//    func testDownloadRange() async throws {
//        let key = "test-01.txt"
//        let contents = "lorem ipsum dolor sit amet"
//        let range: ClosedRange<UInt> = 1...3
//        let expectation = "ore"
//
//        try await os.upload(
//            key: key,
//            buffer: .init(string: contents),
//            checksum: nil,
//            timeout: .seconds(30)
//        )
//
//        let buffer = try await os.download(
//            key: key,
//            range: range,
//            timeout: .seconds(30)
//        )
//        guard let res = buffer.utf8String else {
//            return XCTFail("Invalid byte buffer response data value.")
//        }
//        XCTAssertEqual(res, expectation)
//    }
//
//    func testDownloadRangeStream() async throws {
//        let key = "test-01.txt"
//        let contents = "lorem ipsum dolor sit amet"
//
//        try await os.upload(
//            key: key,
//            buffer: .init(string: contents),
//            checksum: nil,
//            timeout: .seconds(30)
//        )
//
//        let stream = os.download(
//            key: key,
//            chunkSize: 2,
//            timeout: .seconds(30)
//        )
//
//        var chunks: [String] = []
//        for try await buffer in stream {
//            guard let chunk = buffer.utf8String else {
//                return XCTFail("Inavlid chunk data value.")
//            }
//            chunks.append(chunk)
//        }
//        XCTAssertEqual(chunks.joined(), contents)
//    }
}