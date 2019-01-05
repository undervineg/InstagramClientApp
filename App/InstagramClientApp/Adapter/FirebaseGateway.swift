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
    
    func register(email: String, username: String, password: String, profileImage: Data?, completion: @escaping (Result<UserEntity, RegisterUserUseCase.Error>) -> Void) {
        
        firebaseAuth.registerUser(email: email, password: password) { (result) in
            switch result {
            case .failure(let error):
                let useCaseError = self.mapErrorCode(with: error._code)
                completion(.failure(useCaseError))
            
            case .success(let user): self.firebaseStorage.uploadProfileImageData(profileImage, completion: { (error) in
                    if error != nil {
                        
                    }
                })
                
                self.saveUser(userId: user.id, username: username) { error in
                    if error != nil {
                        completion(.failure(.databaseUpdateError))
                    }
                }
                
                let userEntity = UserEntity(id: user.id, email: user.email ?? "", username: username)
                completion(.success(userEntity))
            }
        }
        
    }
    
    private func saveUser(userId: String, username: String, completion: @escaping (Error?) -> Void) {
        let usernameValues = ["username": username]
        let userInfo = [userId: usernameValues]
        self.firebaseDatabase.updateUser(with: userInfo, completion: { (error) in
            print(error?.localizedDescription ?? "database error")
            completion(error)
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
