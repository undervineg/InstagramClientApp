//
//  UserProfileUseCaseTests.swift
//  InstagramEngineTests
//
//  Created by 심승민 on 06/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
@testable import InstagramEngine

class UserProfileUseCaseTests: XCTestCase {

    func test_init_doesNotRequestUserInfo() {
        let (_, client, _) = makeSUT()
        
        XCTAssertEqual(client.requestedCount, 0)
    }
    
    func test_loadProfileTwice_sendMessageToOutputTwice_onSuccess() {
        let (sut, client, output) = makeSUT()

        sut.loadProfile()
        sut.loadProfile()
        
        let user1 = UserEntity(id: "0",
                               email: "dummy1@naver.com",
                               username: "dummy1",
                               profileImageUrl: "http://a-url.com")
        let user2 = UserEntity(id: "1",
                               email: "dummy2@naver.com",
                               username: "dummy2",
                               profileImageUrl: "http://b-url.com")
        client.completeWithSuccess(user1, at: 0)
        client.completeWithSuccess(user2, at: 1)
        
        XCTAssertEqual(output.capturedUser, [user1, user2])
    }
    
    func test_loadProfileTwice_sendErrorMessageToOutputTwice_onFailure() {
        let (sut, client, output) = makeSUT()
        
        sut.loadProfile()
        sut.loadProfile()
        
        client.completeWithFailure(.currentUserNotExist, at: 0)
        client.completeWithFailure(.currentUserIDNotExist, at: 1)
        
        XCTAssertEqual(output.capturedError, [.currentUserNotExist, .currentUserIDNotExist])
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: UserProfileUseCase, client: UserProfileClientStub, output: UserProfileUseCaseOutputDummy) {
        let client = UserProfileClientStub()
        let output = UserProfileUseCaseOutputDummy()
        let sut = UserProfileUseCase(client: client, output: output)
        return (sut, client, output)
    }
    
    private class UserProfileClientStub: UserProfileClient {
        private var messages = [(Result<UserEntity, UserProfileUseCase.Error>) -> Void]()
        
        var requestedCount = 0
        
        func loadCurrentUserInfo(_ completion: @escaping (Result<UserEntity, UserProfileUseCase.Error>) -> Void) {
            requestedCount += 1
            messages.append(completion)
        }
        
        func completeWithSuccess(_ user: UserEntity, at index: Int = 0) {
            messages[index](.success(user))
        }
        
        func completeWithFailure(_ error: UserProfileUseCase.Error, at index: Int = 0) {
            messages[index](.failure(error))
        }
    }
    
    private class UserProfileUseCaseOutputDummy: UserProfileUseCaseOutput {
        var capturedUser = [UserEntity]()
        var capturedError = [UserProfileUseCase.Error]()
        
        func loadUserSucceeded(_ user: UserEntity) {
            capturedUser.append(user)
        }
        
        func loadUserFailed(_ error: UserProfileUseCase.Error) {
            capturedError.append(error)
        }
    }
}
