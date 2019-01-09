//
//  RegisterUserClientAdapter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 08/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import FirebaseAuth
import InstagramEngine

final class RegisterUserClientAdapter: RegisterUserClient {
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
        
        auth.registerUser(email: email, password: password) { [weak self] userCreatedResult in
            switch userCreatedResult {
            case .success(let user):
                /* Upload profile image after user created.*/
                self?.uploadProfileImage(profileImage, { [weak self] imageUploadResult in
                    switch imageUploadResult {
                    case .success(let url):
                        /* Save user info on FIR database after profile image uploaed.*/
                        self?.saveUser(user.id, email, username, url) { error in
                            /* Return the Registered Result */
                            if let error = error {
                                completion(error)
                            }
                            completion(nil)
                        }
                    case .failure(let error):
                        completion(error)
                    }
                })
            case .failure(let error):
                if let useCaseError = self?.mapErrorCode(with: error._code) {
                    completion(useCaseError)
                }
            }
        }
        
    }
    
    private func uploadProfileImage(_ profileImage: Data,
                                    _ completion: @escaping (Result<String, RegisterUserUseCase.Error>) -> Void) {
        
        storage.uploadProfileImageData(profileImage, completion: { (result) in
            switch result {
            case .success(let url):
                completion(.success(url))
            case .failure:
                completion(.failure(.storageUploadError))
            }
        })
    }
    
    private func saveUser(_ userId: String,
                          _ email: String,
                          _ username: String,
                          _ profileImageUrl: String,
                          _ completion: @escaping (RegisterUserUseCase.Error?) -> Void) {
        
        database.updateUser(userId: userId, email: email, username: username, profileImageUrl: profileImageUrl) { (error) in
            if error != nil {
                completion(.databaseUpdateError)
            } else {
                completion(nil)
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
