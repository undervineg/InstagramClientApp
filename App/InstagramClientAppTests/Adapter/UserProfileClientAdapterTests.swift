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

class UserProfileClientAdapterTests: XCTestCase {

    override func tearDown() {
        resetStaticClassProperties()
        super.tearDown()
    }
    
    func test_load_receivesTheRightUserInfo() {
        let (sut, firebase) = makeSUT()
        let dummyUser = UserEntity(id: "0", email: "dummy@naver.com", username: "dummy", profileImageUrl: "http://a-url.com")
        firebase.stubUser(dummyUser)
        firebase.currentUserId = dummyUser.id
        
        var capturedUser = [UserEntity]()
        sut.loadCurrentUserInfo { (result) in
            if case let Result.success(user) = result {
                capturedUser.append(user)
            }
        }
        
        firebase.completeWithLoadUserInfoSuccess()
        
        XCTAssertEqual(capturedUser, [dummyUser])
    }
    
    func test_load_receivesError_onCurrentUserIDNotExist() {
        let (sut, _) = makeSUT()
        
        var capturedError = [UserProfileUseCase.Error]()
        sut.loadCurrentUserInfo { (result) in
            if case let Result.failure(error) = result {
                capturedError.append(error)
            }
        }
        
        XCTAssertEqual(capturedError, [.currentUserIDNotExist])
    }
    
    func test_load_receivesError_onCurrentUserEntityNotExist() {
        let (sut, firebase) = makeSUT()
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

    // MARK: - Helopers
    
    private func makeSUT() -> (sut: UserProfileService, firebase: MockFirebase.Type) {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        let firebase = MockFirebase.self
        let sut = UserProfileService(firebaseAuth: firebase, firebaseDatabase: firebase, firebaseStorage: firebase)
        
        return (sut, firebase)
    }
    
    private func resetStaticClassProperties() {
        MockFirebase.registerMessages = []
        MockFirebase.imageUploadMessages = []
        MockFirebase.updateUserInfoMessages = []
        MockFirebase.loadUserInfoMessages = []
        MockFirebase.currentUserId = nil
        MockFirebase.stubbedUser = [:]
    }
}
