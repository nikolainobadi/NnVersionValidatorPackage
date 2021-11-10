//
//  LocalVersionNumberLoader.swift
//  
//
//  Created by Nikolai Nobadi on 11/10/21.
//

import Foundation

public final class LocalVersionNumberLoader {
    
    // MARK: - Properties
    private let infoDictonary: [String: Any]?
    private let versionStringId = "CFBundleShortVersionString"
    
    public enum Error: Swift.Error {
        case missingVersionId
        case invalidData
        case missingNumber
    }
    
    
    // MARK: - Init
    public init(infoDictionary: [String: Any]?) {
        self.infoDictonary = infoDictionary
    }
}


// MARK: - Loader
extension LocalVersionNumberLoader: VersionNumberLoader {
    
    public func load(completion: @escaping (VersionNumberLoader.Result) -> Void) {
        
        guard
            let deviceVersionString = infoDictonary?[versionStringId] as? String
        else { return completion(.failure(Error.missingVersionId)) }
        
        completion(DeviceVersionMapper.map(deviceVersionString))
    }
}
