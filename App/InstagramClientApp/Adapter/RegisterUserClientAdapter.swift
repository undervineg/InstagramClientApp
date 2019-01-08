//
//  RegisterUserClientAdapter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 08/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import FirebaseAuth
import InstagramEngine

class RegisterUserClientAdapter: RegisterUserClient {
    
    private let auth: FirebaseAuthWrapper.Type
    private let database: FirebaseDatabaseWrapper.Type
    private let storage: FirebaseStorageWrapper.Type
    
    init(firebaseAuth: FirebaseAuthWrapper.Type,
         firebaseDatabase: FirebaseDatabaseWrapper.Type,
         firebaseStorage: FirebaseStorageWrapper.Type) {
        self.auth = firebaseAuth
        self.database = firebaseDatabase
        self.storage = firebaseStorage
    }
    
    func register(email: String, username: String, password: String, profileImage: Data, completion: @escaping (RegisterUserUseCase.Error?) -> Void) {
        
        auth.registerUser(email: email, password: password) { (result) in
            switch result {
            case .failure(let error):
                let useCaseError = self.mapErrorCode(with: error._code)
                completion(useCaseError)
                
            case .success(let user):
                /* Upload profile image after user created.*/
                self.storage.uploadProfileImageData(profileImage, completion: { (result) in
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
        self.database.updateUser(userId: userId, email: email, username: username, profileImageUrl: profileImageUrl) { (error) in
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