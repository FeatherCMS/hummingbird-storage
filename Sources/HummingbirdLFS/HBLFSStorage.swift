import Foundation
import NIOPosix
import NIOCore
import NIOFoundationCompat
import Logging
import HummingbirdStorage

private extension FileManager {

    func directoryExists(at location: URL) -> Bool {
        var isDir: ObjCBool = false
        FileManager.default.fileExists(
            atPath: location.path,
            isDirectory: &isDir
        )
        return isDir.boolValue
    }
    
    func createDirectory(at location: URL) throws {
        try FileManager.default.createDirectory(
            at: location,
            withIntermediateDirectories: true
        )
    }
}

struct HBLFSStorage: HBStorage {
    
    let service: HBLFSStorageService
    let logger: Logger
    let eventLoop: EventLoop
    
    var workUrl: URL { .init(fileURLWithPath: service.workDir) }
}

extension HBLFSStorage {

    func create(
        key: String
    ) async throws {
        try FileManager.default.createDirectory(
            at: workUrl.appendingPathComponent(key),
            withIntermediateDirectories: true
        )
    }

    func list(
        key: String?
    ) async throws -> [String] {
        let dirUrl = workUrl.appendingPathComponent(key ?? "")
        if FileManager.default.directoryExists(at: dirUrl) {
            return try FileManager.default.contentsOfDirectory(
                atPath: dirUrl.path
            )
        }
        return []
    }
    
    func copy(
        key source: String,
        to destination: String
    ) async throws {
        let exists = await exists(key: source)
        guard exists else {
            throw HBStorageError.keyNotExists
        }
        try await delete(key: destination)
        let sourceUrl = workUrl.appendingPathComponent(source)
        let destinationUrl = workUrl.appendingPathComponent(destination)
        let location = destinationUrl.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: location)
        try FileManager.default.copyItem(at: sourceUrl, to: destinationUrl)
    }

    func move(
        key source: String,
        to destination: String
    ) async throws {
        try await copy(key: source, to: destination)
        try await delete(key: source)
    }

    func delete(
        key: String
    ) async throws {
        guard await exists(key: key) else {
            return
        }
        let fileUrl = workUrl.appendingPathComponent(key)
        try FileManager.default.removeItem(atPath: fileUrl.path)
    }

    func exists(key: String) async -> Bool {
        let fileUrl = workUrl.appendingPathComponent(key)
        return FileManager.default.fileExists(atPath: fileUrl.path)
    }
    
    func upload(
        key: String,
        buffer: ByteBuffer
    ) async throws {
        let fileUrl = workUrl.appendingPathComponent(key)
        let location = fileUrl.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: location)

        let fileio = NonBlockingFileIO(threadPool: service.threadPool)
        return try await fileio.openFile(
            path: fileUrl.path,
            mode: .write,
            flags: .allowFileCreation(),
            eventLoop: eventLoop
        )
        .flatMap { handle in
            fileio.write(
                fileHandle: handle,
                buffer: buffer,
                eventLoop: eventLoop
            )
            .flatMapThrowing { _ in
                try handle.close()
            }
        }
        .get()
    }
    
    func download(
        key: String
    ) async throws -> ByteBuffer {
        let exists = await exists(key: key)
        guard exists else {
            throw HBStorageError.keyNotExists
        }
        let sourceUrl = workUrl.appendingPathComponent(key)
        return .init(data: try Data(contentsOf: sourceUrl))
    }
}
