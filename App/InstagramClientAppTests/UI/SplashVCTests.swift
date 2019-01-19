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
        sut.checkIfAuthenticated = {
            callCount += 1
        }
        
        sut.viewDidAppear(false)
        
        XCTAssertEqual(callCount, 1)
    }
    
    func test_displayRegisterScreenIsCalled_routesMainPage() {
        let (sut, router) = makeSUT()
        
        sut.displayMain()
        
        XCTAssertEqual(router.isMainOpened, true)
        XCTAssertEqual(router.isAuthOpened, false)
    }
    
    func test_displayMainScreenIsCalled_routesRegisterPage() {
        let (sut, router) = makeSUT()
        
        sut.displayLogin()
        
        XCTAssertEqual(router.isMainOpened, false)
        XCTAssertEqual(router.isAuthOpened, true)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: SplashViewController, router: MockSplashRouter) {
        let router = MockSplashRouter()
        let sut = SplashViewController(router: router)
        _ = sut.view
        return (sut, router)
    }
    
    private class MockSplashRouter: SplashRouter.Routes {
        var isMainOpened = false
        var isAuthOpened = false
        
        var mainTransition: Transition {
            return ModalTransition()
        }
        
        var authTransition: Transition {
            return ModalTransition()
        }
        
        
        func openAuthPage(_ root: AuthModule.RootType) {
            isAuthOpened = true
        }
        
        func openAuthPage(_ root: AuthModule.RootType, with transition: Transition) {
            isAuthOpened = true
        }
        
        func openAuthPageAsWindowRoot(_ root: AuthModule.RootType, with openMainCallback: @escaping (UIViewController) -> Void) {
            isAuthOpened = true
        }
        
        func openMainPage() {
            isMainOpened = true
        }
        
        func openMainPageAsWindowRoot(with openLoginCallback: @escaping (UIViewController) -> Void) {
            isMainOpened = true
        }
        
        func openMainPage(with transition: Transition) {
            isMainOpened = true
        }
    }

}
