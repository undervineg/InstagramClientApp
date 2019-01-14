//
//  SplashRouterTests.swift
//  InstagramClientAppTests
//
//  Created by 심승민 on 14/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
@testable import InstagramClientApp

class SplashRouterTests: XCTestCase {
    
    func test_openMainPageTwice_opensMainAsRootTwice_whenCallbackExist() {
        let sut = SplashRouter()
        var capturedVC = [UIViewController]()
        sut.openMainCallback = {
            capturedVC.append($0)
        }
        
        sut.openMainPage()
        sut.openMainPage()
        
        XCTAssertEqual(capturedVC.count, 2)
        XCTAssertTrue(capturedVC.first is MainTabBarViewController)
        XCTAssertTrue(capturedVC.last is MainTabBarViewController)
    }
    
    func test_openAuthPage_opensLoginPageWithNavigationControllerAsRoot_whenCallbackExist() {
        let sut = SplashRouter()
        var capturedVC = [UIViewController]()
        sut.openLoginCallback = {
            capturedVC.append($0)
        }
        
        sut.openAuthPage(.login)
        
        XCTAssertEqual(capturedVC.count, 1)
        XCTAssertTrue(capturedVC.first is UINavigationController)
        XCTAssertTrue(capturedVC.first?.children.first is LoginViewController)
    }

}
