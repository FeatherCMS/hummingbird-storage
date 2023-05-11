import Hummingbird
import HummingbirdServices
import Logging

extension HBApplication.Services {

    public var storage: HBStorageService {
        get {
            get(\.services.storage, "Storage service is not configured")
        }
        nonmutating set {
            set(\.services.storage, newValue)
        }
    }
}

extension HBApplication {

    public var storage: HBStorage {
        services.storage.make(
            logger: logger,
            eventLoop: eventLoopGroup.next()
        )
    }
}

extension HBRequest {

    public var storage: HBStorage {
        application.services.storage.make(
            logger: logger,
            eventLoop: eventLoop
        )
    }
}
