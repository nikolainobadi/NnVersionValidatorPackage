//
//  HTTPClient.swift
//  
//
//  Created by Nikolai Nobadi on 11/10/21.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<Data, Error>

    func get(from url: URL, completion: @escaping (Result) -> Void)
}
