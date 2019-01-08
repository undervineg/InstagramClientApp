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
        let gateway = RegisterUserClientSpy()
        let output = RegisterUserUseCaseOutputDummy()
        
        let _ = RegisterUserUseCase.init(client: gateway, output: output)
        
        XCTAssert(gateway.requestedUserInfos.isEmpty)
    }
    
    func test_register_requestsRegisterTheRightUser() {
        let gateway = RegisterUserClientSpy()
        let output = RegisterUserUseCaseOutputDummy()
        let sut = RegisterUserUseCase(client: gateway, output: output)
        let uinfo = UserInfo()
        
        sut.register(email: uinfo.email, username: uinfo.username, password: uinfo.password, profileImage: uinfo.profileImageData) { _ in }
        
        XCTAssertEqual(gateway.requestedUserInfos, [uinfo])
    }

    func test_registerTwice_requestsRegisterTheRightUserTwice() {
        let gateway = RegisterUserClientSpy()
        let output = RegisterUserUseCaseOutputDummy()
        let sut = RegisterUserUseCase(client: gateway, output: output)
        let uinfo = UserInfo()
        
        sut.register(email: uinfo.email, username: uinfo.username, password: uinfo.password, profileImage: uinfo.profileImageData) { _ in }
        sut.register(email: uinfo.email, username: uinfo.username, password: uinfo.password, profileImage: uinfo.profileImageData) { _ in }
        
        XCTAssertEqual(gateway.requestedUserInfos, [uinfo, uinfo])
    }
    
    func test_register_deliversErrorWhenGatewayError() {
        let gateway = RegisterUserClientSpy()
        let output = RegisterUserUseCaseOutputDummy()
        let sut = RegisterUserUseCase(client: gateway, output: output)
        let uinfo = UserInfo()
        
        var capturedErrors = [RegisterUserUseCase.Error]()
        sut.register(email: uinfo.email, username: uinfo.username, password: uinfo.password, profileImage: uinfo.profileImageData) { error in
            if let error = error {
                capturedErrors.append(error)
            }
        }

        gateway.completes(with: RegisterUserUseCase.Error.invalidName)
        
        XCTAssertEqual(capturedErrors, [.invalidName])
    }
    
    
    // MARK: - Helpers
    
    private class RegisterUserClientSpy: RegisterUserClient {
        func fetchCurrentUserInfo() -> UserEntity? {
            return nil
        }
        
        func register(email: String, username: String, password: String, profileImage: Data, completion: @escaping (RegisterUserUseCase.Error?) -> Void) {
            messages.append((email, username, password, profileImage, completion))
        }
        
        private var messages = [(email: String, username: String, password: String, profileImage: Data, completion: (RegisterUserUseCase.Error?) -> Void)]()
        
        var requestedUserInfos: [UserInfo] {
            return messages.map { UserInfo($0.email, $0.username, $0.password, $0.profileImage) }
        }
        
        
        func completes(with error: RegisterUserUseCase.Error, at index: Int = 0) {
            messages[index].completion(error)
        }
    }
    
    private struct UserInfo: Equatable {
        let email: String
        let username: String
        let password: String
        let profileImageData: Data
        
        init() {
            self.email = "testEmail"
            self.username = "testName"
            self.password = "testPassword"
            self.profileImageData = Data()
        }
        
        init(_ email: String, _ username: String, _ password: String, _ profileImageData: Data) {
            self.email = email
            self.username = username
            self.password = password
            self.profileImageData = profileImageData
        }
    }
    
    private class RegisterUserUseCaseOutputDummy: RegisterUserUseCaseOutput {
        
        func registerSucceeded() {
            
        }
        
        func registerFailed(_ error: RegisterUserUseCase.Error) {
            
        }
    }

}
