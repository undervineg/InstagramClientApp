//
//  RegisterRouterTests.swift
//  InstagramClientAppTests
//
//  Created by 심승민 on 04/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
@testable import InstagramClientApp

class RegisterRouterTests: XCTestCase {

    func test_defaultLoginTransitionTypeIsPushTransition() {
        let sut = RegisterRouter()
        
        XCTAssertTrue(sut.loginTransition is PushTransition)
    }
    
    func test_openLoginPage_opensLoginViewController() {
        let sut = RegisterRouter()
        let root = RegisterUserViewController()
        sut.viewControllerBehind = root
        let stubTransition = StubTransition()
        
        sut.openLoginPage(with: stubTransition)
        
        XCTAssertEqual(stubTransition.openedVC.count, 1)
        XCTAssertTrue(stubTransition.openedVC.first is LoginViewController)
        XCTAssertEqual(stubTransition.closedVC.count, 0)
    }
    
}
