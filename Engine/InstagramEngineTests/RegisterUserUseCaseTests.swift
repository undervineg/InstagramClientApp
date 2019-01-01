//
//  RegisterUserUseCaseTests.swift
//  InstagramEngineTests
//
//  Created by 심승민 on 01/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
@testable import InstagramEngine

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
        
        sut.register(email: userInfo.email, username: userInfo.username, password: userInfo.password) { _ in }
        
        XCTAssertEqual(gateway.requestedUserInfos, [userInfo])
    }

    func test_registerTwice_requestsRegisterTheRightUserTwice() {
        let gateway = AuthGatewaySpy()
        let sut = RegisterUserUseCase(gateway: gateway)
        let userInfo = UserInfo(email: "testEmail", username: "testName", password: "testPassword")
        
        sut.register(email: userInfo.email, username: userInfo.username, password: userInfo.password) { _ in }
        sut.register(email: userInfo.email, username: userInfo.username, password: userInfo.password) { _ in }
        
        XCTAssertEqual(gateway.requestedUserInfos, [userInfo, userInfo])
    }
    
    func test_register_deliversErrorWhenGatewayError() {
        let gateway = AuthGatewaySpy()
        let sut = RegisterUserUseCase(gateway: gateway)
        let userInfo = UserInfo(email: "testEmail", username: "testName", password: "testPassword")
        
        sut.register(email: userInfo.email, username: userInfo.username, password: userInfo.password) { _ in }
        
        XCTAssertEqual(gateway.requestedUserInfos, [userInfo, userInfo])
    }
    
    
    // MARK: - Helpers
    
    private class AuthGatewaySpy: AuthGateway {
        var requestedUserInfos = [UserInfo]()
        
        func register(email: String, username: String, password: String, completion: @escaping (Result<UserEntity, Error>) -> Void) {
            requestedUserInfos.append(UserInfo(email: email, username: username, password: password))
        }
    }
    
    private struct UserInfo: Equatable {
        let email: String
        let username: String
        let password: String
    }

}
