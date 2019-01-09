//
//  iOSViewControllerFactoryTests.swift
//  InstagramClientAppTests
//
//  Created by 심승민 on 04/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
import InstagramEngine
@testable import InstagramClientApp

class iOSViewControllerFactoryTests: XCTestCase {

    private var vc: UIViewController?
    
    func test_creates_splashVC() {
        let sut = iOSViewControllerFactory()
        let window = UIWindow()
        let router = SplashRouter(window: window)
        
        let vc = sut.splashViewController(router: router)
        
        XCTAssert(vc is SplashViewController)
    }
    
    func test_creates_resultVC() {
        let sut = iOSViewControllerFactory()
        let router = RegisterRouter()
        
        let vc = sut.registerViewController(router: router)
        
        XCTAssert(vc is RegisterUserViewController)
    }

    func test_creates_userProfileVC() {
        let sut = iOSViewControllerFactory()
        
        let vc = sut.userProfileViewController()
        
        XCTAssert(vc is UserProfileViewController)
    }
}
