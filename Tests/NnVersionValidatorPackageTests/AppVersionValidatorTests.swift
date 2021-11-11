//
//  AppVersionValidatorTests.swift
//  
//
//  Created by Nikolai Nobadi on 11/10/21.
//

import XCTest
import NnVersionValidatorPackage

class AppVersionValidatorTests: XCTestCase {
    
    // MARK: - No Update Required
    func test_checkAppVersion_noUpdateRequired_allNumbersMatch() {
        let (sut, local, remote) = makeSUT()
        
        expect(sut, toCompleteWith: .success(false)) {
            remote.complete(with: .success(makeVersionNumber()))
            local.complete(with: .success(makeVersionNumber()))
        }
    }
    
    func test_checkAppVersion_noUpdateRequired_minorDifferent() {
        let (sut, local, remote) = makeSUT()
        let localVersion = makeVersionNumber()
        let remoteVersion = makeVersionNumber(minor: 5)
        
        expect(sut, toCompleteWith: .success(false)) {
            remote.complete(with: .success(remoteVersion))
            local.complete(with: .success(localVersion))
        }
    }
    
    func test_checkAppVersion_noUpdateRequired_patchDifferent() {
        let (sut, local, remote) = makeSUT()
        let localVersion = makeVersionNumber()
        let remoteVersion = makeVersionNumber(patch: 5)
        
        expect(sut, toCompleteWith: .success(false)) {
            remote.complete(with: .success(remoteVersion))
            local.complete(with: .success(localVersion))
        }
    }
}


// MARK: - Update Required
extension AppVersionValidatorTests {

    func test_checkAppVersion_majorNumType_updateRequired_majorNumDifferent() {
        
        let (sut, local, remote) = makeSUT()
        let localVersion = makeVersionNumber()
        let remoteVersion = makeVersionNumber(major: 5)
        
        expect(sut, toCompleteWith: .success(true)) {
            remote.complete(with: .success(remoteVersion))
            local.complete(with: .success(localVersion))
        }
    }
    
    func test_checkAppVersion_minorNumType_updateRequired_majorNumDifferent() {
        
        let (sut, local, remote) = makeSUT(numberType: .minor)
        let localVersion = makeVersionNumber()
        let remoteVersion = makeVersionNumber(major: 5)
        
        expect(sut, toCompleteWith: .success(true)) {
            remote.complete(with: .success(remoteVersion))
            local.complete(with: .success(localVersion))
        }
    }
    
    func test_checkAppVersion_minorNumType_updateRequired_minorNumDifferent() {
        
        let (sut, local, remote) = makeSUT(numberType: .minor)
        let localVersion = makeVersionNumber()
        let remoteVersion = makeVersionNumber(minor: 5)
        
        expect(sut, toCompleteWith: .success(true)) {
            remote.complete(with: .success(remoteVersion))
            local.complete(with: .success(localVersion))
        }
    }
    
    func test_checkAppVersion_patchNumType_updateRequired_majorNumDifferent() {
        
        let (sut, local, remote) = makeSUT(numberType: .patch)
        let localVersion = makeVersionNumber()
        let remoteVersion = makeVersionNumber(major: 5)
        
        expect(sut, toCompleteWith: .success(true)) {
            remote.complete(with: .success(remoteVersion))
            local.complete(with: .success(localVersion))
        }
    }
    
    func test_checkAppVersion_patchNumType_updateRequired_minorNumDifferent() {
        
        let (sut, local, remote) = makeSUT(numberType: .patch)
        let localVersion = makeVersionNumber()
        let remoteVersion = makeVersionNumber(minor: 5)
        
        expect(sut, toCompleteWith: .success(true)) {
            remote.complete(with: .success(remoteVersion))
            local.complete(with: .success(localVersion))
        }
    }
    
    func test_checkAppVersion_patchNumType_updateRequired_patchNumDifferent() {
        
        let (sut, local, remote) = makeSUT(numberType: .patch)
        let localVersion = makeVersionNumber()
        let remoteVersion = makeVersionNumber(patch: 5)
        
        expect(sut, toCompleteWith: .success(true)) {
            remote.complete(with: .success(remoteVersion))
            local.complete(with: .success(localVersion))
        }
    }
}


// MARK: - Other Errors
extension AppVersionValidatorTests {
    
    func test_checkAppVersion_localError() {
        let (sut, local, remote) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.noConnection)) {
            remote.complete(with: .success(makeVersionNumber()))
            local.complete(with: .failure(LocalVersionNumberLoader.Error.missingNumber))
        }
    }

    func test_checkAppVersion_remoteError() {
        let (sut, local, remote) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.noConnection)) {
            remote.complete(with: .failure(RemoteVersionNumberLoader.Error.noConnection))
            local.complete(with: .success(makeVersionNumber()))
        }
    }
}


// MARK: - SUT
extension AppVersionValidatorTests {
    
    func makeSUT(numberType: VersionNumberType = .major,
                 file: StaticString = #filePath,
                 line: UInt = #line) -> (sut: AppVersionValidator,
                                         local: MockLoader,
                                         remote: MockLoader) {
        let local = MockLoader()
        let remote = MockLoader()
        let loader = VersionLoaderManager(local: local, remote: remote)
        let sut = AppVersionValidator(loader: loader,
                                      versionNumberType: numberType)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, local, remote)
    }
    
    func makeVersionNumber(major: Int = 1, minor: Int = 1, patch: Int = 1) -> VersionNumber {
        
        VersionNumber(majorNum: major, minorNum: minor, patchNum: patch)
    }
    
    func expect(_ sut: AppVersionValidator,
                toCompleteWith expectedResult: Result<Bool, AppVersionValidator.UpdateError>,
                when action: () -> Void,
                file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "validate version number")

        sut.checkIfVersionUpdateIsRequired { receivedResult in
            
            switch (receivedResult, expectedResult) {
                
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems,
                               expectedItems,
                               file: file, line: line)

            case let (.failure(receivedError as AppVersionValidator.UpdateError), .failure(expectedError)):
                
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
    
    func expectError(_ sut: AppVersionValidator,
                     when action: () -> Void,
                     file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "validate version number")

        sut.checkIfVersionUpdateIsRequired { recievedError in
            XCTAssertNotNil(recievedError); exp.fulfill()
        }

        action()

        waitForExpectations(timeout: 0.1)
    }
    
    class MockLoader: VersionNumberLoader {
        private var action: ((VersionNumberLoader.Result) -> Void)?
        
        func load(completion: @escaping (VersionNumberLoader.Result) -> Void) {
            
            action = completion
        }
        
        func complete(with result: VersionNumberLoader.Result) {
            action?(result)
        }
    }
}
