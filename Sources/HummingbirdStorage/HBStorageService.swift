import Logging
import NIOCore

public protocol HBStorageService {

    func make(
        logger: Logger,
        eventLoop: EventLoop
    ) -> HBStorage
}
