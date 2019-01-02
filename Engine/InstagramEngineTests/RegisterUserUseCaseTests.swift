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
        let output = RegisterUserUseCaseOutputDummy()
        
        let _ = RegisterUserUseCase.init(gateway: gateway, output: output)
        
        XCTAssert(gateway.requestedUserInfos.isEmpty)
    }
    
    func test_register_requestsRegisterTheRightUser() {
        let gateway = AuthGatewaySpy()
        let output = RegisterUserUseCaseOutputDummy()
        let sut = RegisterUserUseCase(gateway: gateway, output: output)
        let userInfo = UserInfo(email: "testEmail", username: "testName", password: "testPassword")
        
        sut.register(email: userInfo.email, username: userInfo.username, password: userInfo.password) { _ in }
        
        XCTAssertEqual(gateway.requestedUserInfos, [userInfo])
    }

    func test_registerTwice_requestsRegisterTheRightUserTwice() {
        let gateway = AuthGatewaySpy()
        let output = RegisterUserUseCaseOutputDummy()
        let sut = RegisterUserUseCase(gateway: gateway, output: output)
        let userInfo = UserInfo(email: "testEmail", username: "testName", password: "testPassword")
        
        sut.register(email: userInfo.email, username: userInfo.username, password: userInfo.password) { _ in }
        sut.register(email: userInfo.email, username: userInfo.username, password: userInfo.password) { _ in }
        
        XCTAssertEqual(gateway.requestedUserInfos, [userInfo, userInfo])
    }
    
    func test_register_deliversErrorWhenGatewayError() {
        let gateway = AuthGatewaySpy()
        let output = RegisterUserUseCaseOutputDummy()
        let sut = RegisterUserUseCase(gateway: gateway, output: output)
        let userInfo = UserInfo(email: "testEmail", username: "testName", password: "testPassword")
        
        var capturedErrors = [RegisterUserUseCase.Error]()
        sut.register(email: userInfo.email, username: userInfo.username, password: userInfo.password) {
            if case let Result.failure(error) = $0 {
                capturedErrors.append(error)
            }
        }

        gateway.completes(with: RegisterUserUseCase.Error.invalidName)
        
        XCTAssertEqual(capturedErrors, [.invalidName])
    }
    
    
    // MARK: - Helpers
    
    private class AuthGatewaySpy: AuthGateway {
        private var messages = [(userInfo: UserInfo, completion: (Result<UserEntity, RegisterUserUseCase.Error>) -> Void)]()
        
        var requestedUserInfos: [UserInfo] {
            return messages.map { $0.userInfo }
        }
        
        func register(email: String, username: String, password: String, completion: @escaping (Result<UserEntity, RegisterUserUseCase.Error>) -> Void) {
            messages.append((UserInfo(email: email, username: username, password: password), completion))
        }
        
        func completes(with error: RegisterUserUseCase.Error, at index: Int = 0) {
            messages[index].completion(Result.failure(error))
        }
    }
    
    private struct UserInfo: Equatable {
        let email: String
        let username: String
        let password: String
    }
    
    private class RegisterUserUseCaseOutputDummy: RegisterUserUseCaseOutput {
        func registerSucceeded(_ user: UserEntity) {
            
        }
        
        func registerFailed(_ error: RegisterUserUseCase.Error) {
            
        }
    }

}
