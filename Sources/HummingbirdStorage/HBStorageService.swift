import NIOCore
import Logging

public protocol HBStorageService {

    func make(
        logger: Logger,
        eventLoop: EventLoop
    ) -> HBStorage
}
