import NIOCore
import NIOPosix
import Logging
import HummingbirdStorage

struct HBLFSStorageService: HBStorageService {

    let workDir: String
    let threadPool: NIOThreadPool

    func make(
        logger: Logger,
        eventLoop: EventLoop
    ) -> HBStorage {
        HBLFSStorage(
            service: self,
            logger: logger,
            eventLoop: eventLoop
        )
    }
}

