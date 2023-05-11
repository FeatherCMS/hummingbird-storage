import FeatherS3Storage
import HummingbirdStorage
import Logging
import NIOCore
import SotoCore
import SotoS3

struct HBS3StorageService: HBStorageService {

    let s3: S3

    /// Region
    let region: Region

    /// Bucket
    let bucketName: String

    init(
        aws: AWSClient,
        region: Region,
        bucketName: String,
        endpoint: String? = nil,
        timeout: TimeAmount? = nil
    ) {
        let awsUrl = "https://s3.\(region.rawValue).amazonaws.com"
        let endpoint = endpoint ?? awsUrl
        self.region = region
        self.bucketName = bucketName
        self.s3 = S3(
            client: aws,
            region: region,
            endpoint: endpoint,
            timeout: timeout
        )
    }

    func make(
        logger: Logger,
        eventLoop: EventLoop
    ) -> HBStorage {
        FeatherS3Storage(
            s3: s3,
            bucketName: bucketName,
            logger: logger,
            eventLoop: eventLoop
        )
    }
}
