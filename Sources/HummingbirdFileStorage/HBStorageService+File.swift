import NIOPosix
import Hummingbird
import HummingbirdStorage
import HummingbirdServices

public extension HBApplication.Services {
    
    func setUpLocalStorage(
        workDir: String,
        threadPool: NIOThreadPool
    ) {
        storage = HBLFSStorageService(
            workDir: workDir,
            threadPool: threadPool
        )
    }
}
