//
//  WeakRefTests.swift
//  InstagramClientAppTests
//
//  Created by 심승민 on 08/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
@testable import InstagramClientApp

class WeakRefTests: XCTestCase {
    
    func test_weakRef_holdsAReferenceToGivenObject() {
        let obj = MockObject()
        
        let sut = WeakRef(obj)
        
        XCTAssertEqual(ObjectIdentifier(obj), ObjectIdentifier(sut.object!))
    }

    func test_weakRef_() {
        var obj: MockObject? = MockObject() // cycle = 1
        
        let sut = WeakRef(obj!)     // cycle = 1
        
        obj = nil                   // cycle = 0
        
        XCTAssertNil(sut.object)
    }
    
    
    // MARK: - Helpers
    
    private class MockObject {}
}
