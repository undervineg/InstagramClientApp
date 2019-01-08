//
//  RegisterUserClientAdapterTests.swift
//  InstagramClientAppTests
//
//  Created by 심승민 on 02/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
import InstagramEngine
import Firebase
@testable import InstagramClientApp

/*
 * Role: Register user to firebase
 */
class RegisterUserClientAdapterTests: XCTestCase {
    
    let testImageData = UIImage(named: "profile_selected")?.jpegData(compressionQuality: 0.3)
    
    override func tearDown() {
        MockFirebase.messages = []
        MockFirebase.imageUploadMessages = []
        MockFirebase.updateUserInfoMessages = []
        super.tearDown()
    }
    
    func test_register_deliversError() {
        let (sut, firebase) = makeSUT()
        
        var capturedError = [RegisterUserUseCase.Error]()
        sut.register(email: "dummy@email.com", username: "dummy", password: "1234", profileImage: testImageData!) {
            if let error = $0 {
                capturedError.append(error)
            }
        }
        
        firebase.completeWithFailure(errorCode: AuthErrorCode.invalidEmail.rawValue)
        firebase.completeWithFailure(errorCode: AuthErrorCode.emailAlreadyInUse.rawValue)
        firebase.completeWithFailure(errorCode: AuthErrorCode.userDisabled.rawValue)
        firebase.completeWithFailure(errorCode: AuthErrorCode.wrongPassword.rawValue)
        firebase.completeWithFailure(errorCode: AuthErrorCode.userNotFound.rawValue)
        firebase.completeWithFailure(errorCode: AuthErrorCode.accountExistsWithDifferentCredential.rawValue)
        firebase.completeWithFailure(errorCode: AuthErrorCode.networkError.rawValue)
        firebase.completeWithFailure(errorCode: AuthErrorCode.credentialAlreadyInUse.rawValue)
        
        XCTAssertEqual(capturedError, [.invalidEmail,
                                       .emailAlreadyInUse,
                                       .userDisabled,
                                       .wrongPassword,
                                       .userNotFound,
                                       .accountExistsWithDifferentCredential,
                                       .networkError,
                                       .credentialAlreadyInUse])
    }
    
    func test_uploadProfileImageDataToFIRStorage_onRegisterSuccess() {
        let (sut, firebase) = makeSUT()
        
        sut.register(email: "dummy@gmail.com", username: "dummy", password: "1234", profileImage: testImageData!) { _ in }
        
        firebase.completeWithSuccess(id: "0")
        
        XCTAssertEqual(firebase.uploadedProfileImage, [testImageData])
    }
    
    func test_doNotUploadProfileImageDataToFIRStorage_onRegisterFailuer() {
        let (sut, firebase) = makeSUT()
        
        sut.register(email: "dummy@gmail.com", username: "dummy", password: "1234", profileImage: testImageData!) { _ in }
        
        firebase.completeWithFailure(errorCode: 0)
        
        XCTAssertEqual(firebase.uploadedProfileImage, [])
    }
    
    func test_saveUserToFIRDatabase_onProfileImageUploadSuccess() {
        let (sut, firebase) = makeSUT()
        
        sut.register(email: "dummy@gmail.com", username: "dummy", password: "1234", profileImage: testImageData!) { _ in }
        
        firebase.completeWithSuccess(id: "0") {
            firebase.completeWithImageUploadSuccess()
        }
        
        let userInfo = [["0": ["username": "dummy", "profileImageUrl": "http://test-image.url", "email": "dummy@gmail.com"]]]
        XCTAssertEqual(firebase.updatedUserInfo, userInfo)
    }
    
    func test_doNotSaveUserToFIRDatabase_onProfileImageUploadFailure() {
        let (sut, firebase) = makeSUT()
        
        var capturedError = [RegisterUserUseCase.Error]()
        sut.register(email: "dummy@##gmail##.com", username: "dummy", password: "1234", profileImage: testImageData!) {
            if let error = $0 {
                capturedError.append(error)
            }
        }
        
        firebase.completeWithSuccess(id: "0") {
            firebase.completeWithImageUploadFailure()
        }

        XCTAssertEqual(firebase.updatedUserInfo, [])
        XCTAssertEqual(capturedError, [RegisterUserUseCase.Error.storageUploadError])
    }
    
    func test_register_deliversError_onUpdateDatabaseFailure() {
        let (sut, firebase) = makeSUT()
        
        var capturedError = [RegisterUserUseCase.Error]()
        sut.register(email: "dummy@email.com", username: "dummy", password: "1234", profileImage: testImageData!) {
            if let error = $0 {
                capturedError.append(error)
            }
        }
        
        firebase.completeWithSuccess(id: "0") {
            firebase.completeWithImageUploadSuccess() {
                firebase.completeWithUpdateUserInfoFailure()
            }
        }
        
        XCTAssertEqual(capturedError, [RegisterUserUseCase.Error.databaseUpdateError])
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: RegisterUserClientAdapter, firebase: MockFirebase.Type) {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        let firebase = MockFirebase.self
        let sut = RegisterUserClientAdapter(firebaseAuth: firebase, firebaseDatabase: firebase, firebaseStorage: firebase)
        
        return (sut, firebase)
    }
    
}