//
//  VersionNumber.swift
//  
//
//  Created by Nikolai Nobadi on 11/10/21.
//

import CoreGraphics

public struct VersionNumber: Equatable {
    
    // MARK: - Properties
    public let majorNum: Int
    public let minorNum: Int
    public let patchNum: Int
    
    public var fullVersionNumber: String {
        "\(majorNum).\(minorNum).\(patchNum)"
    }
    
    
    // MARK: - Init
    public init(majorNum: Int, minorNum: Int, patchNum: Int) {
        self.majorNum = majorNum
        self.minorNum = minorNum
        self.patchNum = patchNum
    }
}
