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


final class DeviceVersionMapper {

    private init() {}

    static func map(_ versionString: String) -> VersionNumberLoader.Result {
        let noDecimals = removeDecimals(from: versionString)
        let array = noDecimals.compactMap { Int($0) }
        
        guard array.count == noDecimals.count else {
            return .failure(LocalVersionNumberLoader.Error.missingNumber)
        }
        
        return .success(DeviceVersionMapper.makeVersionNumber(from: array))
    }
}


// MARK: - Private Methods
private extension DeviceVersionMapper {
    
    enum VersionNumberType: Int {
        case major, minor, patch
    }
    
    static func removeDecimals(from string: String) -> [String] {
        string.components(separatedBy: ".")
    }
    
    static func mapToInts(_ versionString: [String]) -> [Int] {
        versionString.compactMap { Int($0) }
    }
    
    static func makeVersionNumber(from array: [Int]) -> VersionNumber {
        VersionNumber(majorNum: getNumber(.major, in: array),
                      minorNum: getNumber(.minor, in: array),
                      patchNum: getNumber(.patch, in: array))
    }
    
    static func getNumber(_ numtype: VersionNumberType,
                          in array: [Int]) -> Int {
        
        let index = numtype.rawValue
        
        return array.count > index ? array[index] : 0
    }
}
