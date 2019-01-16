//
//  UserProfileClientAdapterTests.swift
//  InstagramClientAppTests
//
//  Created by 심승민 on 09/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
import InstagramEngine
import Firebase
@testable import InstagramClientApp

class UserProfileServiceTests: XCTestCase {

    override func tearDown() {
        resetStaticClassProperties()
        super.tearDown()
    }
    
    func test_load_receivesTheRightUserInfo() {
        let (sut, firebase, _) = makeSUT()
        let dummyUser = User(id: "0", email: "dummy@naver.com", username: "dummy", profileImageUrl: "http://a-url.com")
        firebase.stubUser(dummyUser)
        firebase.currentUserId = dummyUser.id
        
        var capturedUser = [User]()
        sut.loadCurrentUserInfo { (result) in
            if case let Result.success(user) = result {
                capturedUser.append(user)
            }
        }
        
        firebase.completeWithLoadUserInfoSuccess()
        
        XCTAssertEqual(capturedUser, [dummyUser])
    }
    
    func test_load_receivesError_onCurrentUserIDNotExist() {
        let (sut, _, _) = makeSUT()
        
        var capturedError = [UserProfileUseCase.Error]()
        sut.loadCurrentUserInfo { (result) in
            if case let Result.failure(error) = result {
                capturedError.append(error)
            }
        }
        
        XCTAssertEqual(capturedError, [.currentUserIDNotExist])
    }
    
    func test_load_receivesError_onCurrentUserEntityNotExist() {
        let (sut, firebase, _) = makeSUT()
        firebase.currentUserId = "0"
        
        var capturedError = [UserProfileUseCase.Error]()
        sut.loadCurrentUserInfo { (result) in
            if case let Result.failure(error) = result {
                capturedError.append(error)
            }
        }
        
        firebase.completeWithLoadUserInfoFailure()
        
        XCTAssertEqual(capturedError, [.currentUserNotExist])
    }
    
    func test_downloadImage_requestsDataFromURL() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, _, client) = makeSUT()
        
        sut.downloadProfileImage(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_downloadImageTwice_requestsDataFromURLTwice() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, _, client) = makeSUT()
        
        sut.downloadProfileImage(from: url) { _ in }
        sut.downloadProfileImage(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_downloadImage_deliversErrorWhenClientError() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, _, client) = makeSUT()
        
        var capturedErrors = [UserProfileUseCase.Error]()
        sut.downloadProfileImage(from: url) {
            if case let Result.failure(error) = $0 {
                capturedErrors.append(error)
            }
        }
        
        let clientError = NSError(domain: "Test", code: 0)
        client.completeWithError(clientError)
        
        XCTAssertEqual(capturedErrors, [.profileImageNotExist])
    }
    
    func test_downloadImage_deliversImageOnSuccess() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, _, client) = makeSUT()
        
        var capturedData = [Data]()
        sut.downloadProfileImage(from: url) {
            if case let Result.success(data) = $0 {
                capturedData.append(data)
            }
        }
        
        let data = Data(bytes: "http://a-given-url.com".utf8)
        client.complete(data: data)
        
        XCTAssertEqual(capturedData, [data])
    }
    

    // MARK: - Helopers
    
    private func makeSUT() -> (sut: UserProfileService, firebase: MockFirebase.Type, client: HTTPClientSpy) {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        let firebase = MockFirebase.self
        let client = HTTPClientSpy()
        let sut = UserProfileService(firebaseAuth: firebase, firebaseDatabase: firebase, firebaseStorage: firebase, networking: client)
        
        return (sut, firebase, client)
    }
    
    private func resetStaticClassProperties() {
        MockFirebase.registerMessages = []
        MockFirebase.imageUploadMessages = []
        MockFirebase.updateUserInfoMessages = []
        MockFirebase.loadUserInfoMessages = []
        MockFirebase.currentUserId = nil
        MockFirebase.stubbedUser = [:]
    }
    
    private class HTTPClientSpy: APIClient {
        private var messages = [(url: URL, completion: (Result<Data, Error>) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
            messages.append((url, completion))
        }
        
        // Methods for test
        
        func completeWithError(_ error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(data: Data, at index: Int = 0) {
            messages[index].completion(.success(data))
        }
    }
}
