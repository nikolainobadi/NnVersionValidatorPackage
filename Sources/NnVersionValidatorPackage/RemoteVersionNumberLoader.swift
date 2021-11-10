//
//  File.swift
//  
//
//  Created by Nikolai Nobadi on 11/10/21.
//

import Foundation

public final class RemoteVersionNumberLoader {
    
    // MARK: - Properties
    private let url: URL
    private let remote: HTTPClient
    
    public enum Error: Swift.Error {
        case noConnection
        case invalidData
    }
    
    
    // MARK: - Init
    public init(url: URL, remote: HTTPClient) {
        self.url = url
        self.remote = remote
    }
}


// MARK: - Loader
extension RemoteVersionNumberLoader: VersionNumberLoader {
    
    public func load(completion: @escaping (VersionNumberLoader.Result) -> Void) {
        
        remote.get(from: url) { result in
            switch result {
            case .success: break
            case .failure:
                completion(.failure(Error.noConnection))
            }
        }
    }
}
