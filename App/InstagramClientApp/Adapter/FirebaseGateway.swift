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
    
    func register(email: String, username: String, password: String, profileImage: Data, completion: @escaping (Result<UserEntity, RegisterUserUseCase.Error>) -> Void) {
        
        firebaseAuth.registerUser(email: email, password: password) { (result) in
            switch result {
            case .failure(let error):
                let useCaseError = self.mapErrorCode(with: error._code)
                completion(.failure(useCaseError))
            
            case .success(let user):
                /* Upload profile image after user created.*/
                self.firebaseStorage.uploadProfileImageData(profileImage, completion: { (result) in
                    switch result {
                    case .success(let url):
                        /* Save user info on FIR database after profile image uploaed.*/
                        self.saveUser(userId: user.id, email: email, username: username, profileImageUrl: url) { result in
                            /* Return the Register Result */
                            switch result {
                            case .success(let userEntity):
                                print(userEntity)
                                completion(.success(userEntity))
                            case .failure:
                                completion(.failure(.databaseUpdateError))
                            }
                        }
                    case .failure:
                        completion(.failure(.storageUploadError))
                    }
                })
            }
        }
        
    }
    
    private func saveUser(userId: String, email: String, username: String, profileImageUrl: String, completion: @escaping (Result<UserEntity, Error>) -> Void) {
        let userInfoValues = ["email": email, "username": username, "profileImageUrl": profileImageUrl]
        let userInfoWithId = [userId: userInfoValues]
        self.firebaseDatabase.updateUser(with: userInfoWithId, completion: { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let userEntity = UserEntity(id: userId, email: email, username: username, profileImageUrl: profileImageUrl)
                completion(.success(userEntity))
            }
        })
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
