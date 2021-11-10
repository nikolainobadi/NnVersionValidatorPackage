//
//  LocalVersionNumberLoaderTests.swift
//  
//
//  Created by Nikolai Nobadi on 11/10/21.
//

import XCTest
import NnVersionValidatorPackage

class LocalVersionNumberLoaderTests: XCTestCase {
    
    // MARK: - Properties
    let versionStringId = "CFBundleShortVersionString"
    
    func test_load_errorIfInfoDictionaryIsNil() {
        expect(makeSUT(), toCompleteWith: .failure(.missingVersionId))
    }
    
    func test_load_errorIfDeviceStringDoesNotContainInts() {
        expect(makeSUT(makeDictionary("invalid")),
               toCompleteWith: .failure(.missingNumber))
    }
    
    func test_load_onlyMajorNumber() {
        let version = makeVersionNumber(major: 1)
        
        expect(makeSUT(makeDictionary("1")),
               toCompleteWith: .success(version))
    }
    
    func test_load_onlyMajorNumberAndMinorNumbers() {
        let version = makeVersionNumber(major: 1, minor: 2)
        
        expect(makeSUT(makeDictionary("1.2")),
               toCompleteWith: .success(version))
    }
    
    func test_load_completeVersionNumber() {
        let version = makeVersionNumber(major: 1, minor: 2, patch: 3)
        
        expect(makeSUT(makeDictionary("1.2.3")),
               toCompleteWith: .success(version))
    }
    
    func test_load_zeroMinorNumber() {
        let version = makeVersionNumber(major: 1, patch: 3)
        
        expect(makeSUT(makeDictionary("1.0.3")),
               toCompleteWith: .success(version))
    }
}


// MARK: - SUT
extension LocalVersionNumberLoaderTests {
    
    func makeSUT(_ infoDictionary: [String: Any]? = nil) -> LocalVersionNumberLoader {
        
        LocalVersionNumberLoader(infoDictionary: infoDictionary)
    }
}


// MARK: - Helper Methods
extension LocalVersionNumberLoaderTests {
    
    func makeVersionNumber(major: Int,
                           minor: Int = 0,
                           patch: Int = 0) -> VersionNumber {
        
        VersionNumber(majorNum: major,
                      minorNum: minor,
                      patchNum: patch)
    }
    
    func makeDictionary(_ versionString: String) -> [String: Any] {
        [versionStringId: versionString]
    }
    
    func expect(_ sut: LocalVersionNumberLoader,
                toCompleteWith expectedResult: Result<VersionNumber, LocalVersionNumberLoader.Error>,
                file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "validate version number")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
                
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems,
                               expectedItems,
                               file: file, line: line)

            case let (.failure(receivedError as LocalVersionNumberLoader.Error), .failure(expectedError)):
                
                XCTAssertEqual(receivedError, expectedError,
                               file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        waitForExpectations(timeout: 0.1)
    }
}
