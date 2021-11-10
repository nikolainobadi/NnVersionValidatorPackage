//
//  VersionNumber.swift
//  
//
//  Created by Nikolai Nobadi on 11/10/21.
//

public struct VersionNumber: Decodable {
    let majorNum: Int
    let minorNum: Int
    let patchNum: Int
    
    var fullVersionNumber: String {
        "\(majorNum).\(minorNum).\(patchNum)"
    }
}
