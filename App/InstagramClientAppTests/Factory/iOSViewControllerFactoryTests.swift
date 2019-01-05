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
        let router = RegisterRouter()
        let useCase = DummyUseCase()
        
        let vc = sut.registerViewController(router: router, registerCallback: useCase.register)
        
        XCTAssert(vc is RegisterUserViewController)
    }

    
    // MARK: - Helpers
    
    private class DummyUseCase: AuthGateway {
        func register(email: String, username: String, password: String, completion: @escaping (Result<UserEntity, RegisterUserUseCase.Error>) -> Void) {
        }
    }
}
