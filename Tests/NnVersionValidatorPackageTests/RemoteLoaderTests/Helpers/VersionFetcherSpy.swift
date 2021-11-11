//
//  HTTPClientSpy.swift
//  
//
//  Created by Nikolai Nobadi on 11/10/21.
//

import XCTest
import NnVersionValidatorPackage

class VersionFetcherSpy: VersionFetcher {
    
    private var actions = [(url: URL,
                             completion: (VersionFetcher.Result) -> Void)]()

    var requestedURLs: [URL] {
        return actions.map { $0.url }
    }

    func get(from url: URL,
             completion: @escaping (VersionFetcher.Result) -> Void) {
        
        actions.append((url, completion))
    }

    func complete(with error: Error,
                  at index: Int = 0,
                  file: StaticString = #filePath,
                  line: UInt = #line) {
        guard
            actions.count > index
        else {
            return XCTFail("Can't complete request never made",
                           file: file, line: line)
        }

        actions[index].completion(.failure(error))
    }

    func complete(data: Data,
                  at index: Int = 0,
                  file: StaticString = #filePath,
                  line: UInt = #line) {
        guard
            requestedURLs.count > index
        else {
            return XCTFail("Can't complete request never made",
                           file: file, line: line)
        }

        actions[index].completion(.success(data))
    }
}
