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
        
        if updateRequired(deviceVersion: deviceVersion, onlineVersion: onlineVersion) {
            
            return completion(UpdateError.updateRequired)
        }
        
        completion(nil)
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
