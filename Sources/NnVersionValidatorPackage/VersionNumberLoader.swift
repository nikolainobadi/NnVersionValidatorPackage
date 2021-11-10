//
//  VersionNumberLoader.swift
//  
//
//  Created by Nikolai Nobadi on 11/10/21.
//

public protocol VersionNumberLoader {
    typealias Result = Swift.Result<VersionNumber, Error>

    func load(completion: @escaping (Result) -> Void)
}
