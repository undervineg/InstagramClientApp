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
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedCount, 0)
    }
    
    func test_loadProfileTwice_loadUserInfoTwice() {
        let (sut, client) = makeSUT()
        
        var capturedUser = [UserEntity]()
        sut.loadProfile { result in
            if case let Result.success(user) = result {
                capturedUser.append(user)
            }
        }
        sut.loadProfile { result in
            if case let Result.success(user) = result {
                capturedUser.append(user)
            }
        }
        
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
        
        XCTAssertEqual(capturedUser, [user1, user2])
    }
    
    func test_loadProfile_deliverscurrentUserNotExistError() {
        let client = UserProfileClientStub()
        let output = UserProfileUseCaseOutputDummy()
        let sut = UserProfileUseCase(client: client, output: output)
        
        var capturedError = [UserProfileUseCase.Error]()
        sut.loadProfile { result in
            if case let Result.failure(error) = result {
                capturedError.append(error)
            }
        }
        
        let clientError = NSError(domain: "test", code: 0)
        client.completeWithFailure(clientError)
        
        XCTAssertEqual(capturedError, [.currentUserNotExist])
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: UserProfileUseCase, client: UserProfileClientStub) {
        let client = UserProfileClientStub()
        let output = UserProfileUseCaseOutputDummy()
        let sut = UserProfileUseCase(client: client, output: output)
        return (sut, client)
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
        
        func completeWithFailure(_ error: Error, at index: Int = 0) {
            messages[index](.failure(.currentUserNotExist))
        }
    }
    
    private class UserProfileUseCaseOutputDummy: UserProfileUseCaseOutput {
        
    }
}
