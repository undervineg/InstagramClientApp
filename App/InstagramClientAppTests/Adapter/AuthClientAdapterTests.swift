//
//  AuthClientAdapterTests.swift
//  InstagramClientAppTests
//
//  Created by 심승민 on 10/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
import InstagramEngine
import Firebase
@testable import InstagramClientApp

class AuthClientAdapterTests: XCTestCase {

    func test_isAuthenticated_succeeded() {
        let firebase = MockFirebase.self
        let sut = AuthClientAdapter(auth: firebase)
        firebase.isAuthenticated = true
        
        var isAuthenticated = false
        sut.checkIfAuthenticated {
            isAuthenticated = $0
        }
        
        XCTAssertEqual(isAuthenticated, true)
    }
    
    func test_isAuthenticated_failed() {
        let firebase = MockFirebase.self
        let sut = AuthClientAdapter(auth: firebase)
        firebase.isAuthenticated = false
        
        var isAuthenticated = false
        sut.checkIfAuthenticated {
            isAuthenticated = $0
        }
        
        XCTAssertEqual(isAuthenticated, false)
    }

}
