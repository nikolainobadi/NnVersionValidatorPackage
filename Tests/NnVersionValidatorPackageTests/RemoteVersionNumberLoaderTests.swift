//
//  AppVersionValidatorTests.swift
//  
//
//  Created by Nikolai Nobadi on 11/10/21.
//

import XCTest
import NnVersionValidatorPackage

class RemoteVersionNumberLoader {
    
    // MARK: - Properties
    let url: URL
    let remote: HTTPClient
    
    enum Error: Swift.Error {
        case noConnection
        case invalidData
    }
    
    
    // MARK: - Init
    init(url: URL, remote: HTTPClient) {
        self.url = url
        self.remote = remote
    }
}


// MARK: - Loader
extension RemoteVersionNumberLoader: VersionNumberLoader {
    
    func load(completion: @escaping (VersionNumberLoader.Result) -> Void) {
        
        remote.get(from: url) { result in
            switch result {
            case .success: break
            case .failure:
                completion(.failure(Error.noConnection))
            }
        }
    }
}

class RemoteVersionNumberLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, remote) = makeSUT()

        XCTAssertTrue(remote.requestedURLs.isEmpty)
    }
    
    func test_validateAppVersion_noConnectionError() {
        let (sut, remote) = makeSUT()

        expect(sut, toCompleteWith: .failure(.noConnection)) {
            let error = NSError(domain: "Test", code: 0)
            remote.complete(with: error)
        }
    }
}


// MARK: - SUT
extension RemoteVersionNumberLoaderTests {
    
    func makeSUT(url: URL = URL(string: "https://a-url.com")!,
                 file: StaticString = #filePath,
                 line: UInt = #line) -> (sut: RemoteVersionNumberLoader,
                                         remote: HTTPClientSpy) {
        let remote = HTTPClientSpy()
        let sut = RemoteVersionNumberLoader(url: url,
                                            remote: remote)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(remote, file: file, line: line)
        
        return (sut, remote)
    }
    
    func expect(_ sut: RemoteVersionNumberLoader,
                toCompleteWith expectedResult: Result<VersionNumber, RemoteVersionNumberLoader.Error>,
                when action: () -> Void,
                file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "validate version number")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
                
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems,
                               expectedItems,
                               file: file, line: line)

            case let (.failure(receivedError as RemoteVersionNumberLoader.Error), .failure(expectedError)):
                
                XCTAssertEqual(receivedError, expectedError,
                               file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()

        waitForExpectations(timeout: 0.1)
    }
}
