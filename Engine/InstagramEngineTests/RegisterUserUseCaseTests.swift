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
        let (_, gateway, _) = makeSUT()
        
        XCTAssert(gateway.requestedUserInfos.isEmpty)
    }
    
    func test_register_requestsRegisterTheRightUser() {
        let (sut, gateway, _) = makeSUT()
        let uinfo = UserInfo()

        sut.register(email: uinfo.email, username: uinfo.username, password: uinfo.password, profileImage: uinfo.profileImageData)

        XCTAssertEqual(gateway.requestedUserInfos, [uinfo])
    }

    func test_registerTwice_requestsRegisterTheRightUserTwice() {
        let (sut, gateway, _) = makeSUT()
        let uinfo = UserInfo()

        sut.register(email: uinfo.email, username: uinfo.username, password: uinfo.password, profileImage: uinfo.profileImageData)
        sut.register(email: uinfo.email, username: uinfo.username, password: uinfo.password, profileImage: uinfo.profileImageData)

        XCTAssertEqual(gateway.requestedUserInfos, [uinfo, uinfo])
    }
    
    func test_registerTwice_sendMessageToOutputTwice_onSuccess() {
        let (sut, gateway, output) = makeSUT()
        
        let uinfo = UserInfo()
        
        sut.register(email: uinfo.email, username: uinfo.username, password: uinfo.password, profileImage: uinfo.profileImageData)
        sut.register(email: uinfo.email, username: uinfo.username, password: uinfo.password, profileImage: uinfo.profileImageData)
        
        gateway.completeWithSuccess(at: 0)
        gateway.completeWithSuccess(at: 1)
        
        XCTAssertEqual(output.successCallCount, 2)
        XCTAssertEqual(output.capturedError, [])
    }
    
    func test_registerTwice_sendErrorMessageToOutputTwice_onFailure() {
        let (sut, gateway, output) = makeSUT()
        
        let uinfo = UserInfo()
        
        sut.register(email: uinfo.email, username: uinfo.username, password: uinfo.password, profileImage: uinfo.profileImageData)
        sut.register(email: uinfo.email, username: uinfo.username, password: uinfo.password, profileImage: uinfo.profileImageData)
        
        gateway.completes(with: .invalidName, at: 0)
        gateway.completes(with: .invalidEmail, at: 1)
        
        XCTAssertEqual(output.capturedError, [.invalidName, .invalidEmail])
        XCTAssertEqual(output.successCallCount, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: RegisterUserUseCase, gateway: RegisterUserClientSpy, output: RegisterUserUseCaseOutputDummy) {
        let gateway = RegisterUserClientSpy()
        let output = RegisterUserUseCaseOutputDummy()
        let sut = RegisterUserUseCase(client: gateway, output: output)
        return (sut, gateway, output)
    }
    
    private class RegisterUserClientSpy: RegisterUserClient {
        private var messages = [(email: String, username: String, password: String, profileImage: Data, completion: (RegisterUserUseCase.Error?) -> Void)]()
        
        var requestedUserInfos: [UserInfo] {
            return messages.map { UserInfo($0.email, $0.username, $0.password, $0.profileImage) }
        }
        
        func register(email: String, username: String, password: String, profileImage: Data, completion: @escaping (RegisterUserUseCase.Error?) -> Void) {
            messages.append((email, username, password, profileImage, completion))
        }
        
        func completeWithSuccess(at index: Int = 0) {
            messages[index].completion(nil)
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
        var successCallCount = 0
        var capturedError = [RegisterUserUseCase.Error]()
        
        func registerSucceeded() {
            successCallCount += 1
        }
        
        func registerFailed(_ error: RegisterUserUseCase.Error) {
            capturedError.append(error)
        }
    }

}
