//
//  VersionNumberMapper.swift
//  
//
//  Created by Nikolai Nobadi on 11/10/21.
//

import Foundation

final class VersionNumberMapper {
    
    private struct RemoteVersionNumber: Decodable {
        let majorNum: Int
        let minorNum: Int
        let patchNum: Int
    }

    private init() {}

    static func map(_ data: Data) -> VersionNumberLoader.Result {
        
        guard
            let number = try? JSONDecoder().decode(RemoteVersionNumber.self, from: data)
        else {
            return .failure(RemoteVersionNumberLoader.Error.invalidData)
        }
        
        return .success(VersionNumber(majorNum: number.majorNum,
                                      minorNum: number.minorNum,
                                      patchNum: number.patchNum))
    }
}
