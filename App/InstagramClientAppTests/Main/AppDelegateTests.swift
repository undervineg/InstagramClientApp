//
//  AppDelegateTests.swift
//  InstagramClientAppTests
//
//  Created by 심승민 on 08/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
import Firebase
import InstagramEngine
@testable import InstagramClientApp

class AppDelegateTests: XCTestCase {
    private weak var weakSUT: StubAppDelegate?
    private weak var weakVC: UIViewController?
    
    override func tearDown() {
        super.tearDown()
        
        assertNoMemoryLeaks()
    }
    
    private func assertNoMemoryLeaks() {
        XCTAssertNil(weakVC)
        XCTAssertNil(weakSUT)
    }
    
    func test_didFinishLaunching_configuresRegisterViewController() {
        let vc = makeVC()
        let sut = makeSUT(with: vc)
        
        _ = sut.application(.shared, didFinishLaunchingWithOptions: [:])
    }
    
    private func makeVC() -> UIViewController {
        let module = SplashModule()
        module.viewController.loadViewIfNeeded()
        weakVC = module.viewController
        return module.viewController
    }
    
    private func makeSUT(with root: UIViewController) -> StubAppDelegate {
        let sut = StubAppDelegate()
        let window = UIWindow()
        window.rootViewController = root
        sut.window = window
        weakSUT = sut
        return sut
    }
    
}
