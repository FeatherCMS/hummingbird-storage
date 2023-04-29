import Hummingbird
import Logging

extension HBApplication {
    
    public struct File {

        let app: HBApplication

        public var storage: HBStorageService {
            get {
                if !app.extensions.exists(\.file.storage) {
                    fatalError("File storage is not configured.")
                }
                return app.extensions.get(\.file.storage)
            }
            nonmutating set {
                app.extensions.set(\.file.storage, value: newValue) { storage in
                    try storage.shutdown()
                }
            }
        }
    }
    
    public var file: File { .init(app: self) }
}

//extension HBRequest {
//
//    var fs: HBStorageService {
//        file.storage.f
//    }
//}
//
//req.fs.upload(key: <#T##String#>)
//req.mail.send()
//req.db.create()
