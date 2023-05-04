import XCTest
import Hummingbird
import HummingbirdStorage
import HummingbirdLFS

private extension ByteBuffer {

    var utf8String: String? {
        guard
            let data = getData(at: 0, length: readableBytes),
            let res = String(data: data, encoding: .utf8)
        else {
            return nil
        }
        return res
    }
}

final class HummingbirdLFSTests: XCTestCase {

    private static var testDir: String = {
        let testPath = #file
            .split(separator: "/")
            .dropLast(2)
            .joined(separator: "/")

        return "/" + testPath + "/tmp/"
    }()

    private func getTestApp() -> HBApplication {
        let app = HBApplication()

        app.services.setUpLocalStorage(
            workDir: Self.testDir,
            threadPool: app.threadPool
        )
        return app
    }
    
    override class func tearDown() {
        try? FileManager.default.removeItem(atPath: testDir)
    }
    
    // MARK: - tests

    func testUpload() async throws {
        let app = getTestApp()
        let key = "test-01.txt"
        let contents = "lorem ipsum dolor sit amet"

        try await app.storage.upload(
            key: key,
            buffer: .init(string: contents)
        )
        let buffer = try await app.storage.download(
            key: key
        )

        guard let res = buffer.utf8String else {
            return XCTFail("Invalid byte buffer response data value.")
        }
        XCTAssertEqual(res, contents)
    }

    func testCreate() async throws {
        let app = getTestApp()
        let key = "dir01/dir02/dir03"
        try await app.storage.create(key: key)

        let list1 = try await app.storage.list(key: "dir01")
        XCTAssertEqual(list1, ["dir02"])

        let list2 = try await app.storage.list(key: "dir01/dir02")
        XCTAssertEqual(list2, ["dir03"])
    }

    func testList() async throws {
        let app = getTestApp()
        let key1 = "dir02/dir03"
        try await app.storage.create(key: key1)

        let key2 = "dir02/test-01.txt"
        try await app.storage.upload(
            key: key2,
            buffer: .init(string: "test")
        )

        let res = try await app.storage.list(key: "dir02")
        XCTAssertEqual(res, ["dir03", "test-01.txt"])
    }

    func testExists() async throws {
        let app = getTestApp()
        let key1 = "non-existing-thing"
        let exists1 = await app.storage.exists(key: key1)
        XCTAssertFalse(exists1)

        let key2 = "my/dir/"
        try await app.storage.create(key: key2)
        let exists2 = await app.storage.exists(key: key2)
        XCTAssertTrue(exists2)
    }

    func testListFile() async throws {
        let app = getTestApp()
        let key = "dir04/test-01.txt"
        try await app.storage.upload(
            key: key,
            buffer: .init(string: "test")
        )

        let res = try await app.storage.list(key: key)
        XCTAssertEqual(res, [])
    }

    func testCopy() async throws {
        let app = getTestApp()
        let key = "test-02.txt"
        try await app.storage.upload(
            key: key,
            buffer: .init(string: "lorem ipsum")
        )

        let dest = "test-03.txt"
        try await app.storage.copy(key: key, to: dest)

        let res1 = await app.storage.exists(key: key)
        XCTAssertTrue(res1)

        let res2 = await app.storage.exists(key: dest)
        XCTAssertTrue(res2)
    }

    func testMove() async throws {
        let app = getTestApp()
        let key = "test-04.txt"
        try await app.storage.upload(
            key: key,
            buffer: .init(string: "dolor sit amet")
        )

        let dest = "test-05.txt"
        try await app.storage.move(key: key, to: dest)

        let res1 = await app.storage.exists(key: key)
        XCTAssertFalse(res1)

        let res2 = await app.storage.exists(key: dest)
        XCTAssertTrue(res2)
    }

    func testDownload() async throws {
        let app = getTestApp()
        let key = "test-04.txt"
        let contents = "lorem ipsum dolor sit amet"

        try await app.storage.upload(
            key: key,
            buffer: .init(string: contents)
        )

        let buffer = try await app.storage.download(
            key: key
        )
        guard let res = buffer.utf8String else {
            return XCTFail("Invalid byte buffer response data value.")
        }
        XCTAssertEqual(res, contents)
    }
}
