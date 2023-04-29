import NIOCore
import Logging

public protocol HBStorageService {
    
    func shutdown() throws

    func make(
        logger: Logger,
        eventLoop: EventLoop
    ) -> HBStorage
}
