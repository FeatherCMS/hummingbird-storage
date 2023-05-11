import FeatherFileStorage
import HummingbirdStorage
import Logging
import NIOCore
import NIOPosix

struct HBFileStorageService: HBStorageService {

    let workDir: String
    let threadPool: NIOThreadPool

    func make(
        logger: Logger,
        eventLoop: EventLoop
    ) -> HBStorage {
        FeatherFileStorage(
            workDir: workDir,
            threadPool: threadPool,
            logger: logger,
            eventLoop: eventLoop
        )
    }
}
