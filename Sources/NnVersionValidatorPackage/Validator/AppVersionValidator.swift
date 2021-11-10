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
        case updateRequired
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
    
    public func checkAppVersion(completion: @escaping (Error?) -> Void) {
        loader.fetchAppVersions { [weak self] result in
            
            switch result {
            case .success(let (deviceVersion, onlineVersion)):
                self?.validateVersions(deviceVersion: deviceVersion,
                                       onlineVersion: onlineVersion,
                                       completion: completion)
            case .failure(let error):
                completion(error)
            }
        }
    }
}


// MARK: - Private Methods
private extension AppVersionValidator {
    
    func validateVersions(deviceVersion: VersionNumber,
                          onlineVersion: VersionNumber,
                          completion: @escaping (Error?) -> Void) {
        
        let deviceNum = getNumberToValidate(from: deviceVersion)
        let onlineNum = getNumberToValidate(from: onlineVersion)
        
        guard deviceNum >= onlineNum else {
            return completion(UpdateError.updateRequired)
        }
        
        completion(nil)
    }
    
    func getNumberToValidate(from version: VersionNumber) -> Int {
        
        switch versionNumberType {
        case .major: return version.majorNum
        case .minor: return version.minorNum
        case .patch: return version.patchNum
        }
    }
}
