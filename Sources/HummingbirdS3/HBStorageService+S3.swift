import NIO
import Logging
import Hummingbird
import HummingbirdStorage
import HummingbirdServices
import SotoS3

public extension HBApplication.Services {
    
    func setUpS3Service(
        using aws: AWSClient,
        region: String,
        bucket: String,
        endpoint: String? = nil,
        timeout: TimeAmount? = nil
    ) {
        storage = HBS3StorageService(
            aws: aws,
            region: .init(rawValue: region),
            bucket: .init(name: bucket),
            endpoint: endpoint,
            timeout: timeout
        )
    }
}
