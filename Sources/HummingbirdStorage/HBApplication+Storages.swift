import Hummingbird

extension HBApplication {
    
    public struct Storage {

        public var objectStorages: ObjectStorages {
            get {
                if !app.extensions.exists(\.storage.objectStorages) {
                    fatalError("Storages is not configured.")
                }
                return app.extensions.get(\.storage.objectStorages)
            }
            nonmutating set {
                app.extensions.set(\.storage.objectStorages, value: newValue) { objectStorages in
                    // NOTE: shutdown?
                }
            }
        }

        let app: HBApplication
    }
    
    public var storage: Storage { .init(app: self) }
    
}
