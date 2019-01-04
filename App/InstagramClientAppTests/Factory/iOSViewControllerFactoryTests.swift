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

    func test_creates_resultViewController() {
        let sut = iOSViewControllerFactory()
        let useCase = DummyUseCase()
        
        let vc = sut.registerViewController(registerCallback: useCase.register)
        
        XCTAssert(vc is RegisterUserViewController)
    }
    
    func test_creates_resultViewController_withCallback() {
        let sut = iOSViewControllerFactory()
        let useCase = DummyUseCase()
        
        let vc = sut.registerViewController(registerCallback: useCase.register) as! RegisterUserViewController
        vc.registerCallback?("", "", "") { _ in }
        
        XCTAssertEqual(useCase.callCount, 1)
    }

    
    // MARK: - Helpers
    
    private class DummyUseCase: AuthGateway {
        var callCount = 0
        func register(email: String, username: String, password: String, completion: @escaping (Result<UserEntity, RegisterUserUseCase.Error>) -> Void) {
            callCount += 1
        }
    }
}
