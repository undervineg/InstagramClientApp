//
//  MainTabBarViewControllerTests.swift
//  InstagramClientAppTests
//
//  Created by 심승민 on 09/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
@testable import InstagramClientApp

class MainTabBarViewControllerTests: XCTestCase {

    func test_init_addChildViewControllers() {
        let dummyVCs = [UIViewController(),
                        UIViewController(),
                        UIViewController(),
                        UIViewController()]
        let router = MockMainRouter()
        
        let sut = MainTabBarViewController.init(subViewControllers: dummyVCs, router: router)
        
        XCTAssertNotNil(sut.viewControllers)
        XCTAssertEqual(sut.viewControllers, dummyVCs)
    }

    
    // MARK: - Helpers
    
    private class MockMainRouter: MainRouter.Routes {
        var loginTransition: Transition = PushTransition()
        var registerTransition: Transition = PushTransition()
        
        func openLoginPage(with transition: Transition?) {
            
        }
        
        func openRegisterPage() {
            
        }
    }
}
