//
//  XCTestCase+MemoryLeakTracking.swift
//  
//
//  Created by Nikolai Nobadi on 11/10/21.
//

import XCTest

extension XCTestCase {
    
    func trackForMemoryLeaks(_ instance: AnyObject,
                             file: StaticString = #filePath,
                             line: UInt = #line) {
        
        addTeardownBlock { [weak instance] in
            
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.",
                         file: file, line: line)
        }
    }
}
