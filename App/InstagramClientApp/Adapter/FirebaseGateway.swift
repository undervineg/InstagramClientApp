//
//  FirebaseGateway.swift
//  InstagramClientApp
//
//  Created by 심승민 on 02/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import FirebaseAuth
import InstagramEngine

final class FirebaseGateway: AuthGateway {
    
    private let firebaseAuth: FirebaseAuthWrapper.Type
    private let firebaseDatabase: FirebaseDatabaseWrapper.Type
    private let firebaseStorage: FirebaseStorageWrapper.Type
    
    init(firebaseAuth: FirebaseAuthWrapper.Type,
         firebaseDatabase: FirebaseDatabaseWrapper.Type,
         firebaseStorage: FirebaseStorageWrapper.Type) {
        self.firebaseAuth = firebaseAuth
        self.firebaseDatabase = firebaseDatabase
        self.firebaseStorage = firebaseStorage
    }
    
    func fetchCurrentUserInfo() -> UserEntity? {
        guard let currentUserId = firebaseAuth.currentUserId else { return nil }
        return firebaseDatabase.fetchUserInfo(currentUserId)
    }
    
    func register(email: String, username: String, password: String, profileImage: Data, completion: @escaping (RegisterUserUseCase.Error?) -> Void) {
        
        firebaseAuth.registerUser(email: email, password: password) { (result) in
            switch result {
            case .failure(let error):
                let useCaseError = self.mapErrorCode(with: error._code)
                completion(useCaseError)
            
            case .success(let user):
                /* Upload profile image after user created.*/
                self.firebaseStorage.uploadProfileImageData(profileImage, completion: { (result) in
                    switch result {
                    case .success(let url):
                        /* Save user info on FIR database after profile image uploaed.*/
                        self.saveUser(userId: user.id, email: email, username: username, profileImageUrl: url) { error in
                            /* Return the Register Result */
                            if error != nil {
                                completion(.databaseUpdateError)
                            }
                        }
                    case .failure:
                        completion(.storageUploadError)
                    }
                })
            }
        }
        
    }
    
    private func saveUser(userId: String, email: String, username: String, profileImageUrl: String, completion: @escaping (Error?) -> Void) {
        self.firebaseDatabase.updateUser(userId: userId, email: email, username: username, profileImageUrl: profileImageUrl) { (error) in
            if let error = error {
                completion(error)
            }
        }
    }
    
    private func mapErrorCode(with errorCode: Int) -> RegisterUserUseCase.Error {
        if let authError = AuthErrorCode(rawValue: errorCode) {
            switch authError {
            case .invalidEmail: return .invalidEmail
            case .emailAlreadyInUse: return .emailAlreadyInUse
            case .userDisabled: return .userDisabled
            case .wrongPassword: return .wrongPassword
            case .userNotFound: return .userNotFound
            case .accountExistsWithDifferentCredential: return .accountExistsWithDifferentCredential
            case .networkError: return .networkError
            case .credentialAlreadyInUse: return .credentialAlreadyInUse
            default: return .unknown
            }
        }
        return .unknown
    }
    
}
