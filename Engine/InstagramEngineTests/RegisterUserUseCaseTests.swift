//
//  RegisterUserUseCaseTests.swift
//  InstagramEngineTests
//
//  Created by 심승민 on 01/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
@testable import InstagramEngine

class RegisterUserUseCase {
    private let gateway: AuthGateway
    
    init(gateway: AuthGateway) {
        self.gateway = gateway
    }
    
    func register(email: String, username: String, password: String) {
        gateway.register(email: email, username: username, password: password) { (result) in
            
        }
    }
}

/*
 * SUT: RegisterUserUseCase
 * Dependencies: RegisterUserGateway, RegisterUserUseCaseOutput
 */
class RegisterUserUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestRegister() {
        let gateway = AuthGatewaySpy()
        
        let _ = RegisterUserUseCase.init(gateway: gateway)
        
        XCTAssert(gateway.requestedUserInfos.isEmpty)
    }
    
    func test_register_requestsRegisterTheRightUser() {
        let gateway = AuthGatewaySpy()
        let sut = RegisterUserUseCase(gateway: gateway)
        let userInfo = UserInfo(email: "testEmail", username: "testName", password: "testPassword")
        
        sut.register(email: userInfo.email, username: userInfo.username, password: userInfo.password)
        
        XCTAssertEqual(gateway.requestedUserInfos, [userInfo])
    }

    func test_registerTwice_requestsRegisterTheRightUserTwice() {
        let gateway = AuthGatewaySpy()
        let sut = RegisterUserUseCase(gateway: gateway)
        let userInfo = UserInfo(email: "testEmail", username: "testName", password: "testPassword")
        
        sut.register(email: userInfo.email, username: userInfo.username, password: userInfo.password)
        sut.register(email: userInfo.email, username: userInfo.username, password: userInfo.password)
        
        XCTAssertEqual(gateway.requestedUserInfos, [userInfo, userInfo])
    }
    
    
    // MARK: - Helpers
    
    private class AuthGatewaySpy: AuthGateway {
        var requestedUserInfos = [UserInfo]()
        
        func register(email: String, username: String, password: String, completion: @escaping (Result) -> Void) {
            requestedUserInfos.append(UserInfo(email: email, username: username, password: password))
        }
    }
    
    private struct UserInfo: Equatable {
        let email: String
        let username: String
        let password: String
    }

}
