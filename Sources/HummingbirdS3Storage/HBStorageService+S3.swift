import Hummingbird
import HummingbirdServices
import SotoCore

public extension HBApplication.Services {

    func setUpS3Storage(
        using aws: AWSClient,
        region: String,
        bucket: String,
        endpoint: String? = nil,
        timeout: TimeAmount? = nil
    ) {
        storage = HBS3StorageService(
            aws: aws,
            region: .init(rawValue: region),
            bucketName: bucket,
            endpoint: endpoint,
            timeout: timeout
        )
    }
}
