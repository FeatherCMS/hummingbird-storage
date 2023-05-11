import Hummingbird
import HummingbirdServices
import HummingbirdStorage
import NIOPosix

extension HBApplication.Services {

    public func setUpFileStorage(
        workDir: String,
        threadPool: NIOThreadPool
    ) {
        storage = HBFileStorageService(
            workDir: workDir,
            threadPool: threadPool
        )
    }
}
