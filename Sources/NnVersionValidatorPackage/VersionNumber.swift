//
//  VersionNumber.swift
//  
//
//  Created by Nikolai Nobadi on 11/10/21.
//

public struct VersionNumber: Equatable {
    public let majorNum: Int
    public let minorNum: Int
    public let patchNum: Int
    
    public var fullVersionNumber: String {
        "\(majorNum).\(minorNum).\(patchNum)"
    }
}
