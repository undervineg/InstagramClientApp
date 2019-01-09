//
//  MockFirebase.swift
//  InstagramClientAppTests
//
//  Created by 심승민 on 08/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine
import Firebase
@testable import InstagramClientApp

// Auth를 상속받아서 메소드를 오버라이드 할 수도 있지만, extension에서 정의한 메소드는 오버라이드하지 못 한다. 따라서 프로토콜로 대체
class MockFirebase: FirebaseAuthWrapper, FirebaseDatabaseWrapper, FirebaseStorageWrapper {
    
    // MARK: - Properties for Protocols
    
    static var isAuthenticated: Bool = false
    static var currentUserId: String?
    
    
    // MARK: - Methods for Protocols
    
    static func registerUser(email: String, password: String, completion: @escaping (Result<(id: String, email: String?), Error>) -> Void) {
        registerMessages.append((email, password, completion))
    }
    
    static func uploadProfileImageData(_ imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        imageUploadMessages.append((imageData, completion))
    }
    
    static func updateUser(userId: String, email: String, username: String, profileImageUrl: String, completion: @escaping (Error?) -> Void) {
        let userInfo = [
            userId: [
                "email": email,
                "username": username,
                "profileImageUrl": profileImageUrl
            ]
        ]
        updateUserInfoMessages.append((userInfo, completion))
    }
    
    static func fetchUserInfo(_ userId: String, completion: @escaping (UserEntity?) -> Void) {
        loadUserInfoMessages.append((userId, completion))
    }
    
    
    
    // MARK: - Properties for Mock
    
    static var stubbedUser: [String: UserEntity] = [:]
    
    static var registerMessages = [(email: String, pw: String, completed: (Result<(id: String, email: String?), Error>) -> Void)]()
    static var capturedEmail: [String] {
        return registerMessages.map { $0.email }
    }
    
    static var imageUploadMessages = [(imageData: Data, completion: (Result<String, Error>) -> Void)]()
    static var uploadedProfileImage: [Data] {
        return imageUploadMessages.map { $0.imageData }
    }
    
    static var updateUserInfoMessages = [(userInfo: [String : [String: String]], completion: (Error?) -> Void)]()
    static var updatedUserInfo: [[String: [String: String]]] {
        return updateUserInfoMessages.map { $0.userInfo }
    }
    
    static var loadUserInfoMessages = [(userId: String, completion: (UserEntity?) -> Void)]()
    
    
    // MARK: - Helper Methods for Mock
    
    static func stubUser(_ user: UserEntity) {
        stubbedUser.updateValue(user, forKey: user.id)
    }
    
    static func completeWithRegisterSuccess(id: String, at index: Int = 0, completion: () -> Void = {}) {
        registerMessages[index].completed(.success((id: id, email: capturedEmail[index])))
        completion()
    }
    
    static func completeWithRegisterFailure(errorCode: Int, at index: Int = 0) {
        let error = NSError(domain: "test", code: errorCode)
        registerMessages[index].completed(.failure(error))
    }
    
    static func completeWithImageUploadSuccess(at index: Int = 0, completion: () -> Void = {}) {
        imageUploadMessages[index].completion(.success("http://test-image.url"))
        completion()
    }
    
    static func completeWithImageUploadFailure(at index: Int = 0) {
        let error = NSError(domain: "test", code: 0)
        imageUploadMessages[index].completion(.failure(error))
    }
    
    static func completeWithUpdateUserInfoSuccess(at index: Int = 0, completion: () -> Void = {}) {
        updateUserInfoMessages[index].completion(nil)
        completion()
    }
    
    static func completeWithUpdateUserInfoFailure(at index: Int = 0) {
        let error = NSError(domain: "test", code: 0)
        updateUserInfoMessages[index].completion(error)
    }
    
    static func completeWithLoadUserInfoSuccess(with uid: String, at index: Int = 0) {
        if let user = stubbedUser[uid] {
            loadUserInfoMessages[index].completion(user)
        }
    }
    
    static func completeWithLoadUserInfoSuccess(at index: Int = 0) {
        if let userId = currentUserId,
            loadUserInfoMessages[index].userId == userId,
            let user = stubbedUser[userId] {
            loadUserInfoMessages[index].completion(user)
        }
    }
    
    static func completeWithLoadUserInfoFailure(at index: Int = 0) {
        loadUserInfoMessages[index].completion(nil)
    }
    
}
