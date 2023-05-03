import NIOCore
import Logging
import HummingbirdStorage
import SotoS3
import SotoCore

struct HBS3StorageService: HBStorageService {

    let s3: S3
    
    /// Region
    let region: Region
    
    /// Bucket
    let bucket: S3.Bucket

    init(
        client: AWSClient,
        region: Region,
        bucket: S3.Bucket,
        endpoint: String? = nil,
        timeout: TimeAmount? = nil
    ) {
        let awsUrl = "https://s3.\(region.rawValue).amazonaws.com"
        let endpoint = endpoint ?? awsUrl
        self.region = region
        self.bucket = bucket
        self.s3 = S3(
            client: client,
            region: region,
            endpoint: endpoint,
            timeout: timeout
        )
    }

    func make(
        logger: Logger,
        eventLoop: EventLoop
    ) -> HBStorage {
        HBS3Storage(
            service: self,
            logger: logger,
            eventLoop: eventLoop
        )
    }
    
    func shutdown() throws {
        
    }
}

extension HBS3StorageService {

    var regionName: String { region.rawValue }

    var bucketName: String { bucket.name! }
}
