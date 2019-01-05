//
//  FirebaseGatewayTests.swift
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
class FirebaseGatewayTests: XCTestCase {
    
    override func tearDown() {
        MockFirebase.messages = []
        MockFirebase.updatedUserInfo = []
        MockFirebase.uploadedProfileImage = []
        super.tearDown()
    }
    
    func test_register_deliversTheRightCurrentUser() {
        let (sut, firebase) = makeSUT()
        
        var capturedUser = [UserEntity]()
        sut.register(email: "dummy@email.com", username: "dummy", password: "1234", profileImage: nil) {
            if case let Result.success(user) = $0 {
                capturedUser.append(user)
            }
        }
        
        firebase.completeWithSuccess(id: "0")
        
        let user = UserEntity(id: "0", email: "dummy@email.com", username: "dummy")
        XCTAssertEqual(capturedUser.count, 1)
        XCTAssertEqual(capturedUser, [user])
    }
    
    func test_registerTwice_deliversTheRightCurrentUserTwice() {
        let (sut, firebase) = makeSUT()

        var capturedUser = [UserEntity]()
        sut.register(email: "dummy@email.com", username: "dummy", password: "1234", profileImage: nil) {
            if case let Result.success(user) = $0 {
                capturedUser.append(user)
            }
        }
        sut.register(email: "dummy2@email.com", username: "dummy2", password: "1234", profileImage: nil) {
            if case let Result.success(user) = $0 {
                capturedUser.append(user)
            }
        }
        
        firebase.completeWithSuccess(id: "0", at: 0)
        firebase.completeWithSuccess(id: "1", at: 1)
        
        
        let user1 = UserEntity(id: "0", email: "dummy@email.com", username: "dummy")
        let user2 = UserEntity(id: "1", email: "dummy2@email.com", username: "dummy2")
        XCTAssertEqual(capturedUser.count, 2)
        XCTAssertEqual(capturedUser, [user1, user2])
    }
    
    func test_register_deliversMappingError() {
        let (sut, firebase) = makeSUT()
        
        var capturedError = [RegisterUserUseCase.Error]()
        sut.register(email: "dummy@email.com", username: "dummy", password: "1234", profileImage: nil) {
            if case let Result.failure(error) = $0 {
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
    
    func test_saveUserToFIRDatabase_onRegisterSuccess() {
        let (sut, firebase) = makeSUT()
        
        sut.register(email: "dummy@gmail.com", username: "dummy", password: "1234", profileImage: nil) { _ in }
        
        firebase.completeWithSuccess(id: "0")
        
        let userInfo = [["0": ["username": "dummy"]]]
        XCTAssertEqual(firebase.updatedUserInfo, userInfo)
    }
    
    func test_doNotSaveUserToFIRDatabase_onRegisterFailure() {
        let (sut, firebase) = makeSUT()
        
        sut.register(email: "dummy@##gmail##.com", username: "dummy", password: "1234", profileImage: nil) { _ in }
        
        firebase.completeWithFailure(errorCode: AuthErrorCode.invalidEmail.rawValue)

        XCTAssertEqual(firebase.updatedUserInfo, [])
    }
    
    func test_uploadProfileImageDataToFIRStorage_onRegisterSuccess() {
        let (sut, firebase) = makeSUT()

        let testImageData = UIImage(named: "test_image")?.jpegData(compressionQuality: 0.3)
        sut.register(email: "dummy@gmail.com", username: "dummy", password: "1234", profileImage: testImageData) { _ in }

        firebase.completeWithSuccess(id: "0")

        XCTAssertEqual(firebase.uploadedProfileImage, [testImageData])
    }
    
    func test_doNotUploadProfileImageDataToFIRStorage_onRegisterFailuer() {
        let (sut, firebase) = makeSUT()
        
        let testImageData = UIImage(named: "test_image")?.jpegData(compressionQuality: 0.3)
        sut.register(email: "dummy@gmail.com", username: "dummy", password: "1234", profileImage: testImageData) { _ in }
        
        firebase.completeWithFailure(errorCode: 0)
        
        XCTAssertEqual(firebase.uploadedProfileImage, [])
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: FirebaseGateway, firebase: MockFirebase.Type) {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        let firebase = MockFirebase.self
        let sut = FirebaseGateway(firebaseAuth: firebase, firebaseDatabase: firebase, firebaseStorage: firebase)
        
        return (sut, firebase)
    }
    
    // Auth를 상속받아서 메소드를 오버라이드 할 수도 있지만, extension에서 정의한 메소드는 오버라이드하지 못 한다. 따라서 프로토콜로 대체
    private class MockFirebase: FirebaseAuthWrapper, FirebaseDatabaseWrapper, FirebaseStorageWrapper {
        
        // MARK: - Properties for Mock
        
        static var messages = [(email: String, pw: String, completed: (Result<(id: String, email: String?), Error>) -> Void)]()
        static var capturedEmail: [String] {
            return messages.map { $0.email }
        }
        static var updatedUserInfo: [[String: [String: String]]] = []
        static var uploadedProfileImage: [Data?] = []
        
        // MARK: - Methods for Mock
        
        static func completeWithSuccess(id: String, at index: Int = 0) {
            messages[index].completed(.success((id: id, email: capturedEmail[index])))
        }
        
        static func completeWithFailure(errorCode: Int, at index: Int = 0) {
            let error = NSError(domain: "test", code: errorCode)
            messages[index].completed(.failure(error))
        }
        
        // MARK: - Methods for Protocols
        
        static func registerUser(email: String, password: String, completion: @escaping (Result<(id: String, email: String?), Error>) -> Void) {
            messages.append((email, password, completion))
        }
        
        static func updateUser(with userInfo: [String : Any], completion: @escaping (Error?) -> Void) {
            updatedUserInfo.append(userInfo as! [String : [String : String]])
        }
        
        static func uploadProfileImageData(_ imageData: Data?, completion: @escaping (Error?) -> Void) {
            uploadedProfileImage.append(imageData)
        }
    }
}
