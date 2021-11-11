//
//  AppVersionValidatorTests.swift
//  
//
//  Created by Nikolai Nobadi on 11/10/21.
//

import XCTest
import NnVersionValidatorPackage

class RemoteVersionNumberLoaderTests: XCTestCase {
    
    // MARK: - Init Test
    func test_init_doesNotRequestDataFromURL() {
        let (_, remote) = makeSUT()

        XCTAssertTrue(remote.requestedURLs.isEmpty)
    }
    
    
    // MARK: - Errors
    func test_load_noConnectionError() {
        let (sut, remote) = makeSUT()

        expect(sut, toCompleteWith: .failure(.noConnection)) {
            let error = NSError(domain: "Test", code: 0)
            remote.complete(with: error)
        }
    }
    
    func test_load_invalidDataWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .failure(.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(data: invalidJSON)
        }
    }
    
    
    // MARK: - Success
    func test_load_success() {
        let (sut, client) = makeSUT()
        let versionNumber = makeVersionNumber()
        
        expect(sut, toCompleteWith: .success(versionNumber)) {
            client.complete(data: makeJSON())
        }
    }
}


// MARK: - SUT
extension RemoteVersionNumberLoaderTests {
    
    func makeSUT(url: URL = URL(string: "https://a-url.com")!,
                 file: StaticString = #filePath,
                 line: UInt = #line) -> (sut: RemoteVersionNumberLoader,
                                         remote: VersionFetcherSpy) {
        let remote = VersionFetcherSpy()
        let sut = RemoteVersionNumberLoader(url: url,
                                            remote: remote)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(remote, file: file, line: line)
        
        return (sut, remote)
    }
}


// MARK: - Helper Methods
extension RemoteVersionNumberLoaderTests {
    
    func makeVersionNumber() -> VersionNumber {
        VersionNumber(majorNum: 4, minorNum: 0, patchNum: 5)
    }
    
    func makeJSON() -> Data {
        let json = ["majorNum": 4, "minorNum": 0, "patchNum": 5]
        
        return try! JSONSerialization.data(withJSONObject: json)
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
