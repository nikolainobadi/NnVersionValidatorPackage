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
        case invalidData
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
        else { return completion(.failure(Error.invalidData)) }
        
        completion(DeviceVersionMapper.map(deviceVersionString))
    }
}


final class DeviceVersionMapper {

    private init() {}

    static func map(_ versionString: String?) -> VersionNumberLoader.Result {
        
        guard
            let versionString = versionString,
            let array = mapToInts(versionString),
            array.count == versionString.count
        else {
            return .failure(LocalVersionNumberLoader.Error.invalidData)
        }
        
        return .success(DeviceVersionMapper.makeVersionNumber(from: array))
    }
}


// MARK: - Private Methods
private extension DeviceVersionMapper {
    
    enum VersionNumberType: Int {
        case major, minor, patch
    }
    
    static func mapToInts(_ versionString: String) -> [Int]? {
        versionString
            .components(separatedBy: ".")
            .compactMap { Int($0) }
    }
    
    static func makeVersionNumber(from array: [Int]) -> VersionNumber {
        VersionNumber(majorNum: getNumber(.major, in: array),
                      minorNum: getNumber(.minor, in: array),
                      patchNum: getNumber(.pat, in: array))
    }
    
    static func getNumber(_ numtype: VersionNumberType,
                          in array: [Int]) -> Int {
        
        let index = numtype.rawValue
        
        return array.count > index ? array[index] : 0
    }
}
