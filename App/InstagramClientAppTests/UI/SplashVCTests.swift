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
        let (sut, _) = makeSUT()
        
        var callCount = 0
        sut.checkIfAuthenticatedCallback = {
            callCount += 1
        }
        
        sut.viewDidAppear(false)
        
        XCTAssertEqual(callCount, 1)
    }
    
    func test_displayRegisterScreenIsCalled_routesMainPage() {
        let (sut, router) = makeSUT()
        
        sut.displayMain()
        
        XCTAssertEqual(router.isMainOpened, true)
        XCTAssertEqual(router.isRegisterOpened, false)
    }
    
    func test_displayMainScreenIsCalled_routesRegisterPage() {
        let (sut, router) = makeSUT()
        
        sut.displayRegister()
        
        XCTAssertEqual(router.isMainOpened, false)
        XCTAssertEqual(router.isRegisterOpened, true)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: SplashViewController, router: MockSplashRouter) {
        let router = MockSplashRouter()
        let sut = SplashViewController(router: router)
        _ = sut.view
        return (sut, router)
    }
    
    private class MockSplashRouter: SplashRouter.Route {
        var isMainOpened = false
        var isRegisterOpened = false
        
        func openMainPage() {
            isMainOpened = true
        }
        
        func openRegisterPage() {
            isRegisterOpened = true
        }
        
        // MARK: - Unused
        
        func prepareMainScreen() -> UIViewController {
            return MainTabBarViewController()
        }
        
        func prepareRegisterScreen() -> UIViewController {
            return RegisterUserViewController()
        }
        
        var registerTransition: Transition {
            return PushTransition()
        }
    }

}
