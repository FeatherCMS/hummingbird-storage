import NIOCore
import NIOPosix
import Logging
import HummingbirdStorage
import FeatherFileStorage

struct HBLFSStorageService: HBStorageService {

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

