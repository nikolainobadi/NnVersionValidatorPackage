//
//  AppVersionValidatorTests.swift
//  
//
//  Created by Nikolai Nobadi on 11/10/21.
//

import XCTest
import NnVersionValidatorPackage

protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

    func get(from url: URL, completion: @escaping (Result) -> Void)
}



class AppVersionValidator {
    
    // MARK: - Properties
    let versionURL: URL
    let remote: HTTPClient
    
    typealias Result = Swift.Result<VersionNumber, Error>
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    
    // MARK: - Init
    init(versionURL: URL,
         remote: HTTPClient) {
        
        self.versionURL = versionURL
        self.remote = remote
    }
    
    func validateAppVersion(completion: @escaping (Error?) -> Void) {
        
        
    }
}

class AppVersionValidatorTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, remote) = makeSUT()

        XCTAssertTrue(remote.requestedURLs.isEmpty)
    }
}


// MARK: - SUT
extension AppVersionValidatorTests {
    
    func makeSUT(url: URL = URL(string: "https://a-url.com")!,
                 file: StaticString = #filePath,
                 line: UInt = #line) -> (sut: AppVersionValidator,
                                         remote: HTTPClientSpy) {
        let remote = HTTPClientSpy()
        let sut = AppVersionValidator(versionURL: url,
                                      remote: remote)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(remote, file: file, line: line)
        
        return (sut, remote)
    }
    
    class HTTPClientSpy: HTTPClient {
        
        private var actions = [(url: URL,
                                 completion: (HTTPClient.Result) -> Void)]()

        var requestedURLs: [URL] {
            return actions.map { $0.url }
        }

        func get(from url: URL,
                 completion: @escaping (HTTPClient.Result) -> Void) {
            
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

        func complete(withStatusCode code: Int,
                      data: Data,
                      at index: Int = 0,
                      file: StaticString = #filePath,
                      line: UInt = #line) {
            guard
                requestedURLs.count > index
            else {
                return XCTFail("Can't complete request never made",
                               file: file, line: line)
            }

            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!

            actions[index].completion(.success((data, response)))
        }
    }
}
