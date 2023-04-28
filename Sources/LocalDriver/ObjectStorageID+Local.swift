//
//  ObjectStorageID+Local.swift
//  LiquidLocalDriver
//
//  Created by Tibor Bodecs on 2020. 05. 02..
//

import HummingbirdStorage

public extension ObjectStorageID {
    
    /// local file storage identifier
    static let local: ObjectStorageID = .init(string: "local")
}
