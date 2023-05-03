import HummingbirdStorage
import SotoS3
import Foundation

struct HBS3Storage {
	
    let service: HBS3StorageService
    let logger: Logger
    let eventLoop: EventLoop

	init(
        service: HBS3StorageService,
        logger: Logger,
        eventLoop: EventLoop
    ) {
        self.service = service
        self.logger = logger
        self.eventLoop = eventLoop
    }
}

extension HBS3Storage: HBStorage {

    ///
    /// Creates an empty key (directory)
    ///
    func create(
        key: String
    ) async throws {
        let safeKey = key.split(separator: "/").joined(separator: "/") + "/"
        _ = try await service.s3.putObject(
            .init(
                bucket: service.bucketName,
                contentLength: 0,
                key: safeKey
            ),
            logger: logger,
            on: eventLoop
        )
    }

    ///
    /// List objects under a given key (returning the relative keys)
    ///
    func list(
        key: String? = nil
    ) async throws -> [String] {
        let list = try await service.s3.listObjects(
            .init(
                bucket: service.bucketName,
                prefix: key
            ),
            logger: logger,
            on: eventLoop
        )
        let keys = (list.contents ?? []).map(\.key).compactMap { $0 }
        var dropCount = 0
        if let prefix = key {
            dropCount = prefix.split(separator: "/").count
        }
        return keys.compactMap {
            $0.split(separator: "/").dropFirst(dropCount).map(String.init).first
        }
    }
    
    ///
    /// Check if a file exists using a key
    ///
    func exists(
        key: String
    ) async -> Bool {
        do {
            _ = try await service.s3.getObject(
                .init(
                    bucket: service.bucketName,
                    key: key
                ),
                logger: logger,
                on: eventLoop
            )
            return true
        }
        catch {
            return false
        }
    }
    
    ///
    /// Copy existing object to a new key
    ///
    func copy(
        key source: String,
        to destination: String
    ) async throws {
        let exists = await exists(key: source)
        guard exists else {
            throw HBStorageError.keyNotExists
        }
        
        _ = try await service.s3.copyObject(
            .init(
                bucket: service.bucketName,
                copySource: service.bucketName + "/" + source,
                key: destination
            ),
            logger: logger,
            on: eventLoop
        )
    }
    
    ///
    /// Move existing object to a new key
    ///
    func move(
        key source: String,
        to destination: String
    ) async throws {
        let exists = await exists(key: source)
        guard exists else {
            throw HBStorageError.keyNotExists
        }
        _ = try await copy(key: source, to: destination)
        try await delete(key: source)
    }

    ///
    /// Removes a file resource using a key
    ///
    func delete(
        key: String
    ) async throws -> Void {
        _ = try await service.s3.deleteObject(
            .init(
                bucket: service.bucketName,
                key: key
            ),
            logger: logger,
            on: eventLoop
        )
    }

    // MARK: - upload / download
    
    func upload<T: AsyncSequence & Sendable>(
        key: String,
        sequence: T,
        size: Int? = nil,
        timeout: TimeAmount? = nil
    ) async throws where T.Element == ByteBuffer {
        let customS3 = service.s3.with(timeout: timeout)
        _ = try await customS3.putObject(
            .init(
                body: .asyncSequence(sequence, size: size),
                bucket: service.bucketName,
                key: key
            ),
            logger: logger,
            on: eventLoop
        )
    }
    
    ///
    /// Uploads a file using a key and a data object returning the resolved URL of the uploaded file
    ///
    func upload(
        key: String,
        buffer: ByteBuffer,
        timeout: TimeAmount? = nil
    ) async throws {
        let customS3 = service.s3.with(timeout: timeout)
        _ = try await customS3.putObject(
            .init(
                body: .byteBuffer(buffer),
                bucket: service.bucketName,
                key: key
            ),
            logger: logger,
            on: eventLoop
        )
    }

    ///
    /// Download object data using a key
    ///
    func download(
        key source: String,
        timeout: TimeAmount? = nil
    ) async throws -> ByteBuffer {
        let exists = await exists(key: source)
        guard exists else {
            throw HBStorageError.keyNotExists
        }
        let customS3 = service.s3.with(timeout: timeout)
        let response = try await customS3.getObject(
            .init(
                bucket: service.bucketName,
                key: source
            ),
            logger: logger,
            on: eventLoop
        )
        guard let buffer = response.body?.asByteBuffer() else {
            throw HBStorageError.invalidResponse
        }
        return buffer
    }

    func download(
        key: String,
        chunkSize: Int = 5 * 1024 * 1024,
        timeout: TimeAmount? = nil
    ) -> AsyncThrowingStream<ByteBuffer, Error> {
        .init { c in
            Task {
                do {
                    let customS3 = service.s3.with(timeout: timeout)
                    _ = try await customS3.multipartDownload(
                        .init(
                            bucket: service.bucketName,
                            key: key
                        ),
                        partSize: chunkSize,
                        logger: logger,
                        on: eventLoop
                    ) { buffer, size, eventLoop in
                        c.yield(buffer)
                        return eventLoop.makeSucceededVoidFuture()
                    }
                    .get()

                    c.finish()
                }
                catch {
                    c.finish(throwing: error)
                }
            }
        }
    }
}
