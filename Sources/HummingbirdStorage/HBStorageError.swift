public enum HBStorageError: Error {

    /// Key does not exist
    case keyNotExists
    
    /// Invalid checksum
    case invalidChecksum
    
    /// Invalid response
    case invalidResponse
}
