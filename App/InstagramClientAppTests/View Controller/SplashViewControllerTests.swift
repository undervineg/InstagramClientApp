//
//  SplashViewControllerTests.swift
//  InstagramClientAppTests
//
//  Created by 심승민 on 10/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
@testable import InstagramClientApp

class SplashViewControllerTests: XCTestCase {

    func test_startCheckingAuthentication_onViewDidAppear() {
        let sut = SplashViewController()
        
        var callCount = 0
        sut.checkIfAuthenticatedCallback = {
            callCount += 1
        }
        
        _ = sut.view
        sut.viewDidAppear(false)
        
        XCTAssertEqual(callCount, 1)
    }
    
    func test_displayRegisterScreenIsCalled_whenAuthenticateSucceeded() {
        
    }
    
    func test_displayMainScreenIsCalled_whenAuthenticateFailed() {
        
    }

}
