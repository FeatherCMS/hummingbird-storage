import XCTest
import NIO
import Logging
import Hummingbird
import HummingbirdStorage
import HummingbirdFoundation
import LocalDriver

extension ByteBuffer {

    var utf8String: String? {
        guard
            let data = getData(at: 0, length: readableBytes),
            let res = String(data: data, encoding: .utf8)
        else {
            return nil
        }
        return res
    }
}

open class LocalDriverTestCase: XCTestCase {
    
    private func createLocalDriver() -> ObjectStorage {
        let logger = Logger(label: "test-logger")
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let pool = NIOThreadPool(numberOfThreads: 1)
        let fileio = NonBlockingFileIO(threadPool: pool)
        pool.start()

        app = HBApplication()
        app.middleware.add(HBFileMiddleware(application: app!))
        
        app.storage.objectStorages = ObjectStorages(
            eventLoopGroup: eventLoopGroup,
            byteBufferAllocator: .init(),
            fileio: fileio
        )
        
        app.storage.objectStorages.use(
            .local(publicUrl: "http://localhost:8080/",
                    publicPath: "public",
                    workDirectory: "assets"),
            as: .local
        )
        
        return app.storage.objectStorages.make(
            logger: logger,
            on: eventLoopGroup.next())!
    }
    
    private var app: HBApplication!
    var os: ObjectStorage!
 
    open override func setUp() {
        os = createLocalDriver()
        super.setUp()
    }

    open override func tearDown() {
        app.storage.objectStorages.shutdown()
        super.tearDown()
    }
    
}
