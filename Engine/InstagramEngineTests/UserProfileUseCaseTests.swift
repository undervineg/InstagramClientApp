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
        client.completeLoadUserInfoWithSuccess(user1, at: 0)
        client.completeLoadUserInfoWithSuccess(user2, at: 1)
        
        XCTAssertEqual(output.capturedUser, [user1, user2])
    }
    
    func test_loadProfileTwice_sendErrorMessageToOutputTwice_onFailure() {
        let (sut, client, output) = makeSUT()
        
        sut.loadProfile()
        sut.loadProfile()
        
        client.completeLoadUserInfoWithFailure(.currentUserNotExist, at: 0)
        client.completeLoadUserInfoWithFailure(.currentUserIDNotExist, at: 1)
        
        XCTAssertEqual(output.capturedError, [.currentUserNotExist, .currentUserIDNotExist])
    }
    
    func test_downloadProfileImageTwice_sendImageDataToOutputTwice_onSuccess() {
        let (sut, client, output) = makeSUT()
        let user1 = UserEntity(id: "0",
                               email: "dummy1@naver.com",
                               username: "dummy1",
                               profileImageUrl: "http://a-url.com")
        let user2 = UserEntity(id: "1",
                               email: "dummy2@naver.com",
                               username: "dummy2",
                               profileImageUrl: "http://b-url.com")
        
        sut.downloadProfileImage(from: user1.profileImageUrl)
        sut.downloadProfileImage(from: user2.profileImageUrl)
        
        let data1 = Data(bytes: "http://a-url.com".utf8)
        let data2 = Data(bytes: "http://b-url.com".utf8)
        client.completeDownloadProfileImageWithSuccess(data1, at: 0)
        client.completeDownloadProfileImageWithSuccess(data2, at: 1)
        
        XCTAssertEqual(output.capturedImageData, [data1, data2])
    }
    
    func test_downloadProfileImage_sendErrorMessageToOutput_onFailure() {
        let (sut, client, output) = makeSUT()
        
        let user1 = UserEntity(id: "0",
                               email: "dummy1@naver.com",
                               username: "dummy1",
                               profileImageUrl: "http://a-url.com")
        
        sut.downloadProfileImage(from: user1.profileImageUrl)
        client.completeDownloadProfileImageWithFailure(.profileImageNotExist)
        
        XCTAssertEqual(output.capturedError, [.profileImageNotExist])
    }

    
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: UserProfileUseCase, client: UserProfileClientStub, output: UserProfileUseCaseOutputDummy) {
        let client = UserProfileClientStub()
        let output = UserProfileUseCaseOutputDummy()
        let sut = UserProfileUseCase(client: client, output: output)
        return (sut, client, output)
    }
    
    private class UserProfileClientStub: UserProfileClient {
        
        private var loadUserInfoMessages = [(Result<UserEntity, UserProfileUseCase.Error>) -> Void]()
        private var downloadImageMessages = [(url: String, completion: (Result<Data, UserProfileUseCase.Error>) -> Void)]()
        
        var requestedCount = 0
        
        func loadCurrentUserInfo(_ completion: @escaping (Result<UserEntity, UserProfileUseCase.Error>) -> Void) {
            requestedCount += 1
            loadUserInfoMessages.append(completion)
        }
        
        func downloadProfileImage(from url: String, completion: @escaping (Result<Data, UserProfileUseCase.Error>) -> Void) {
            downloadImageMessages.append((url, completion))
        }
        
        // Methods for test
        
        func completeLoadUserInfoWithSuccess(_ user: UserEntity, at index: Int = 0) {
            loadUserInfoMessages[index](.success(user))
        }
        
        func completeLoadUserInfoWithFailure(_ error: UserProfileUseCase.Error, at index: Int = 0) {
            loadUserInfoMessages[index](.failure(error))
        }
        
        func completeDownloadProfileImageWithSuccess(_ data: Data, at index: Int = 0) {
            downloadImageMessages[index].completion(.success(data))
        }
        
        func completeDownloadProfileImageWithFailure(_ error: UserProfileUseCase.Error, at index: Int = 0) {
            downloadImageMessages[index].completion(.failure(error))
        }
    }
    
    private class UserProfileUseCaseOutputDummy: UserProfileUseCaseOutput {
        var capturedUser = [UserEntity]()
        var capturedImageData = [Data]()
        var capturedError = [UserProfileUseCase.Error]()
        
        func loadUserSucceeded(_ user: UserEntity) {
            capturedUser.append(user)
        }
        
        func loadUserFailed(_ error: UserProfileUseCase.Error) {
            capturedError.append(error)
        }
        
        func downloadProfileImageSucceeded(_ imageData: Data) {
            capturedImageData.append(imageData)
        }
        
        func downloadProfileImageFailed(_ error: UserProfileUseCase.Error) {
            capturedError.append(error)
        }
    }
}
