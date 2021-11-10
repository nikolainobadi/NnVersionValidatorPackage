//
//  File.swift
//  
//
//  Created by Nikolai Nobadi on 11/10/21.
//

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
