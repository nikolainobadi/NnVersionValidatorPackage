//
//  VersionLoaderManager.swift
//  
//
//  Created by Nikolai Nobadi on 11/10/21.
//

import Foundation

public final class VersionLoaderManager {
    
    // MARK: - Properties
    private let local: VersionNumberLoader
    private let remote: VersionNumberLoader
    
    
    // MARK: - Init
    public init(local: VersionNumberLoader,
                remote: VersionNumberLoader) {
        
        self.local = local
        self.remote = remote
    }
}


// MARK: - Public Methods
extension VersionLoaderManager {
    
    typealias Result = Swift.Result<(deviceVersion: VersionNumber, onlineVersion: VersionNumber), Error>
    
    func fetchAppVersions(completion: @escaping (Result) -> Void) {
        remote.load { [weak self] result in
            self?.fetchDeviceVersion(result, completion: completion)
        }
    }
}


// MARK: - Private Methods
private extension VersionLoaderManager {
    
    func fetchDeviceVersion(_ result: Swift.Result<VersionNumber, Error>, completion: @escaping (Result) -> Void) {
        
        switch result {
        case .success(let onlineVersion):
            handleFinalFetchResult(onlineVersion, completion)
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    func handleFinalFetchResult(_ onlineVersion: (VersionNumber),
                           _ completion: @escaping (Result) -> Void) {
        
        local.load(completion: { localResult in
            switch localResult {
            case .success(let deviceVersion):
                completion(.success((deviceVersion, onlineVersion)))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
}
