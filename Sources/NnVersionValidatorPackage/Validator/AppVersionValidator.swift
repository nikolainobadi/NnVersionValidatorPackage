//
//  AppVersionValidator.swift
//  
//
//  Created by Nikolai Nobadi on 11/10/21.
//

public final class AppVersionValidator {
    
    // MARK: - Properties
    private let loader: VersionLoaderManager
    
    private var versionNumberType: VersionNumberType
    
    public enum UpdateError: Swift.Error {
        case noConnection
    }
    
    
    // MARK: - Init
    public init(loader: VersionLoaderManager,
                versionNumberType: VersionNumberType = .major) {
        
        self.loader = loader
        self.versionNumberType = versionNumberType
    }
}


// MARK: - Public Methods
extension AppVersionValidator {
    
    public func checkIfVersionUpdateIsRequired(completion: @escaping (Result<Bool, Error>) -> Void) {
        
        loader.fetchAppVersions { [weak self] result in
            
            switch result {
            case .success(let (deviceVersion, onlineVersion)):
                self?.validateVersions(deviceVersion: deviceVersion,
                                       onlineVersion: onlineVersion,
                                       completion: completion)
            case .failure:
                completion(.failure(UpdateError.noConnection))
            }
        }
    }
}


// MARK: - Private Methods
private extension AppVersionValidator {
    
    func validateVersions(deviceVersion: VersionNumber,
                          onlineVersion: VersionNumber,
                          completion: @escaping (Result<Bool, Error>) -> Void) {
        completion(.success(
            updateRequired(deviceVersion: deviceVersion,
                           onlineVersion: onlineVersion))
        )
    }
    
    func updateRequired(deviceVersion: VersionNumber,
                        onlineVersion: VersionNumber) -> Bool {
        
        let majorUpdate = deviceVersion.majorNum < onlineVersion.majorNum
        let minorUpdate = deviceVersion.minorNum < onlineVersion.minorNum
        let patchUpdate = deviceVersion.patchNum < onlineVersion.patchNum
        
        switch versionNumberType {
        case .major: return majorUpdate
        case .minor: return majorUpdate || minorUpdate
        case .patch: return majorUpdate || minorUpdate || patchUpdate
        }
    }
}
