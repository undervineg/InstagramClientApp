//
//  SplashPresenterTests.swift
//  InstagramClientAppTests
//
//  Created by 심승민 on 10/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
@testable import InstagramClientApp

class SplashPresenterTests: XCTestCase {

    func test_displayMain_whenAuthSucceeded() {
        let view = StubSplashView()
        let sut = SplashPresenter(view: view)
        
        sut.authSucceeded()
        
        XCTAssertEqual(view.isMainDisplayed, true)
        XCTAssertEqual(view.isRegisterDisplayed, false)
    }
    
    func test_displayRegister_whenAuthFailed() {
        let view = StubSplashView()
        let sut = SplashPresenter(view: view)
        
        sut.authFailed()
        
        XCTAssertEqual(view.isMainDisplayed, false)
        XCTAssertEqual(view.isRegisterDisplayed, true)
    }

    
    // MARK: - Helpers
    
    private class StubSplashView: SplashView {
        var isMainDisplayed = false
        var isRegisterDisplayed = false
        
        func displayMain() {
            isMainDisplayed = true
        }
        
        func displayLogin() {
            isRegisterDisplayed = true
        }
    }
}
