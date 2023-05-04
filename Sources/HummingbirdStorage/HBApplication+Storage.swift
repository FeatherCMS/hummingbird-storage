import Hummingbird
import HummingbirdServices
import Logging

public extension HBApplication.Services {

    var storage: HBStorageService {
        get {
            get(\.services.storage, "Storage service is not configured")
        }
        nonmutating set {
            set(\.services.storage, newValue)
        }
    }
}

public extension HBApplication {

    var storage: HBStorage {
        services.storage.make(
            logger: logger,
            eventLoop: eventLoopGroup.next()
        )
    }
}

public extension HBRequest {

    var storage: HBStorage {
        application.services.storage.make(
            logger: logger,
            eventLoop: eventLoop
        )
    }
}
