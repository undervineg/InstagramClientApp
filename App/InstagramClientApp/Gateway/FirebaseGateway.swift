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
    
    private let firebase: FirebaseAuthWrapper.Type
    
    init(firebase: FirebaseAuthWrapper.Type) {
        self.firebase = firebase
    }
    
    func register(email: String, username: String, password: String, completion: @escaping (Result<UserEntity, RegisterUserUseCase.Error>) -> Void) {
        
        firebase.registerUser(email: email, password: password) { (result) in
            switch result {
            case .failure(let error):
                let useCaseError = self.mapErrorCode(with: error._code)
                completion(.failure(useCaseError))
            case .success(let user):
                let userEntity = UserEntity(id: user.id, email: user.email ?? "", username: user.name ?? "")
                completion(.success(userEntity))
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
