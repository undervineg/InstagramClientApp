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
        let uinfo = UserInfo()
        
        sut.register(email: uinfo.email, username: uinfo.username, password: uinfo.password, profileImage: uinfo.profileImageData) { _ in }
        
        XCTAssertEqual(gateway.requestedUserInfos, [uinfo])
    }

    func test_registerTwice_requestsRegisterTheRightUserTwice() {
        let gateway = AuthGatewaySpy()
        let output = RegisterUserUseCaseOutputDummy()
        let sut = RegisterUserUseCase(gateway: gateway, output: output)
        let uinfo = UserInfo()
        
        sut.register(email: uinfo.email, username: uinfo.username, password: uinfo.password, profileImage: uinfo.profileImageData) { _ in }
        sut.register(email: uinfo.email, username: uinfo.username, password: uinfo.password, profileImage: uinfo.profileImageData) { _ in }
        
        XCTAssertEqual(gateway.requestedUserInfos, [uinfo, uinfo])
    }
    
    func test_register_deliversErrorWhenGatewayError() {
        let gateway = AuthGatewaySpy()
        let output = RegisterUserUseCaseOutputDummy()
        let sut = RegisterUserUseCase(gateway: gateway, output: output)
        let uinfo = UserInfo()
        
        var capturedErrors = [RegisterUserUseCase.Error]()
        sut.register(email: uinfo.email, username: uinfo.username, password: uinfo.password, profileImage: uinfo.profileImageData) {
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
        
        func register(email: String, username: String, password: String, profileImage: Data?, completion: @escaping (Result<UserEntity, RegisterUserUseCase.Error>) -> Void) {
            messages.append((UserInfo(email, username, password, profileImage), completion))
        }
        
        func completes(with error: RegisterUserUseCase.Error, at index: Int = 0) {
            messages[index].completion(Result.failure(error))
        }
    }
    
    private struct UserInfo: Equatable {
        let email: String
        let username: String
        let password: String
        let profileImageData: Data?
        
        init() {
            self.email = "testEmail"
            self.username = "testName"
            self.password = "testPassword"
            self.profileImageData = UIImage(named: "test_image")?.jpegData(compressionQuality: 0.3)
        }
        
        init(_ email: String, _ username: String, _ password: String, _ profileImageData: Data?) {
            self.email = email
            self.username = username
            self.password = password
            self.profileImageData = profileImageData
        }
    }
    
    private class RegisterUserUseCaseOutputDummy: RegisterUserUseCaseOutput {
        func registerSucceeded(_ user: UserEntity) {
            
        }
        
        func registerFailed(_ error: RegisterUserUseCase.Error) {
            
        }
    }

}
