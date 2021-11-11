//
//  VersionFetcher.swift
//  
//
//  Created by Nikolai Nobadi on 11/10/21.
//

import Foundation

public protocol VersionFetcher {
    typealias Result = Swift.Result<Data, Error>

    func get(from url: URL, completion: @escaping (Result) -> Void)
}
