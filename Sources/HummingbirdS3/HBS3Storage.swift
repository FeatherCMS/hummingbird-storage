import HummingbirdStorage
import SotoS3

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
    
    func getAvailableSpace() -> UInt64 {
        .max
    }

    ///
    /// Resolves a file location using a key and the public endpoint URL string
    ///
    func resolve(
        key: String
    ) -> String {
        service.publicEndpoint + "/" + key
    }
    
    func upload<T: AsyncSequence & Sendable>(
        sequence: T,
        size: UInt,
        key: String,
        checksum: String?,
        timeout: TimeAmount
    ) async throws where T.Element == ByteBuffer {
//        do {
//            let customS3 = s3.with(timeout: timeout)
//            _ = try await customS3.putObject(
//                .init(
//                    acl: .publicRead,
//                    body: .asyncSequence(sequence, size: Int(size)),
//                    bucket: service.bucketName,
//                    checksumAlgorithm: (checksum != nil) ? .crc32 : .none,
//                    checksumCRC32: checksum,
//                    key: key
//                ),
//                logger: logger,
//                on: eventLoop
//            )
//        }
//        catch let error as SotoCore.AWSResponseError {
//            if
//                let ctx = error.context,
//                ctx.responseCode == .badRequest,
//                ctx.message == "Value for x-amz-checksum-crc32 header is invalid."
//            {
//                throw HBStorageError.invalidChecksum
//            }
//            throw error
//        }
    }
    
    
    
    ///
    /// Uploads a file using a key and a data object returning the resolved URL of the uploaded file
    ///
    func upload(
        key: String,
        buffer: ByteBuffer,
        checksum: String?,
        timeout: TimeAmount
    ) async throws {
//        do {
//            let customS3 = s3.with(timeout: timeout)
//            _ = try await customS3.putObject(
//                .init(
//                    acl: .publicRead,
//                    body: .byteBuffer(buffer),
//                    bucket: service.bucketName,
//                    checksumAlgorithm: (checksum != nil) ? .crc32 : .none,
//                    checksumCRC32: checksum,
//                    key: key
//                ),
//                logger: logger,
//                on: eventLoop
//            )
//        }
//        catch let error as SotoCore.AWSResponseError {
//            if
//                let ctx = error.context,
//                ctx.responseCode == .badRequest,
//                ctx.message == "Value for x-amz-checksum-crc32 header is invalid."
//            {
//                throw HBStorageError.invalidChecksum
//            }
//            throw error
//        }
    }
    
    // MARK: - multipart upload

    func createMultipartUpload(
        key: String
    ) async throws -> MultipartUpload.ID {
        let res = try await service.s3.createMultipartUpload(
            .init(
                acl: .publicRead,
                bucket: service.bucketName,
                key: key
            ),
            logger: logger,
            on: eventLoop
        )
        guard let uploadId = res.uploadId else {
            fatalError()
        }
        return .init(uploadId)
    }
    
    func uploadMultipartChunk(
        key: String,
        buffer: ByteBuffer,
        uploadId: MultipartUpload.ID,
        partNumber: Int,
        timeout: TimeAmount
    ) async throws -> MultipartUpload.Chunk {
        let customS3 = service.s3.with(timeout: timeout)
        let res = try await customS3.uploadPart(
            .init(
                body: .byteBuffer(buffer),
                bucket: service.bucketName,
                key: key,
                partNumber: partNumber,
                uploadId: uploadId.value
            ),
            logger: logger,
            on: eventLoop
        )
        guard let etag = res.eTag else {
            throw HBStorageError.invalidResponse
        }
        return .init(id: etag, number: partNumber)
    }
        
    func uploadMultipartChunk<T: AsyncSequence & Sendable>(
        key: String,
        sequence: T,
        size: UInt,
        uploadId: MultipartUpload.ID,
        partNumber: Int,
        timeout: TimeAmount
    ) async throws -> MultipartUpload.Chunk where T.Element == ByteBuffer {
        let customS3 = service.s3.with(timeout: timeout)
        let res = try await customS3.uploadPart(
            .init(
                body: .asyncSequence(sequence, size: Int(size)),
                bucket: service.bucketName,
                key: key,
                partNumber: partNumber,
                uploadId: uploadId.value
            ),
            logger: logger,
            on: eventLoop
        )
        guard let etag = res.eTag else {
            throw HBStorageError.invalidResponse
        }
        return .init(id: etag, number: partNumber)
    }
    
    func cancelMultipartUpload(
        key: String,
        uploadId: MultipartUpload.ID
    ) async throws {
        _ = try await service.s3.abortMultipartUpload(
            .init(
                bucket: service.bucketName,
                key: key,
                uploadId: uploadId.value
            ),
            logger: logger,
            on: eventLoop
        )
    }
    
    func completeMultipartUpload(
        key: String,
        uploadId: MultipartUpload.ID,
        checksum: String?,
        chunks: [MultipartUpload.Chunk],
        timeout: TimeAmount
    ) async throws {
        let parts = chunks.map { chunk -> S3.CompletedPart in
            .init(
                eTag: chunk.id,
                partNumber: chunk.number
            )
        }
        do {
            let customS3 = service.s3.with(timeout: timeout)
            _ = try await customS3.completeMultipartUpload(
                .init(
                    bucket: service.bucketName,
                    checksumCRC32: checksum,
                    key: key,
                    multipartUpload: .init(parts: parts),
                    uploadId: uploadId.value
                ),
                logger: logger,
                on: eventLoop
            )
        }
        catch let error as SotoCore.AWSResponseError {
            if
                let ctx = error.context,
                ctx.responseCode == .badRequest,
                ctx.message == "Value for x-amz-checksum-crc32 header is invalid."
            {
                throw HBStorageError.invalidChecksum
            }
            throw error
        }
    }

    ///
    /// Creates an empty key (directory)
    ///
    func create(
        key: String
    ) async throws {
        _ = try await service.s3.putObject(
            .init(
                acl: .publicRead,
                bucket: service.bucketName,
                contentLength: 0,
                key: key
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
                acl: .publicRead,
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
    /// Download object data using a key
    ///
    func download(
        key source: String,
        range: ClosedRange<UInt>?,
        timeout: TimeAmount
    ) async throws -> ByteBuffer {
        let exists = await exists(key: source)
        guard exists else {
            throw HBStorageError.keyNotExists
        }
        let byteRange = range.map { "bytes=\($0.lowerBound)-\($0.upperBound)" }
        let customS3 = service.s3.with(timeout: timeout)
        let response = try await customS3.getObject(
            .init(
                bucket: service.bucketName,
                key: source,
                range: byteRange
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
        chunkSize: UInt,
        timeout: TimeAmount
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
                        partSize: Int(chunkSize),
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
}
