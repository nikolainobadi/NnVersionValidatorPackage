//
//  AppVersionValidator.swift
//  
//
//  Created by Nikolai Nobadi on 11/10/21.
//

public final class AppVersionValidator {
    
    // MARK: - Properties
    private let local: VersionNumberLoader
    private let remote: VersionNumberLoader
    
    private var versionNumberType: VersionNumberType
    
    public enum UpdateError: Swift.Error {
        case updateRequired
    }
    
    
    // MARK: - Init
    public init(local: VersionNumberLoader,
                remote: VersionNumberLoader,
                versionNumberType: VersionNumberType = .major) {
        
        self.local = local
        self.remote = remote
        self.versionNumberType = versionNumberType
    }
}


// MARK: - Public Methods
extension AppVersionValidator {
    
    public func checkAppVersion(completion: @escaping (Error?) -> Void) {
        fetchAppVersions { [weak self] result in
            
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
    
    typealias Result = Swift.Result<(deviceVersion: VersionNumber, onlineVersion: VersionNumber), Error>
    
    func fetchAppVersions(completion: @escaping (Result) -> Void) {
        remote.load { [weak self] result in
            self?.fetchDeviceVersion(result, completion: completion)
        }
    }
    
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
