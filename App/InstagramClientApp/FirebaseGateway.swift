//
//  FirebaseGateway.swift
//  InstagramClientApp
//
//  Created by 심승민 on 02/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import FirebaseAuth
import InstagramEngine

protocol FirebaseWrapper {
    func registerUser(email: String, password: String, completion: @escaping (Result<(id: String, email: String?, name: String?), Error>) -> Void)
}

extension Auth: FirebaseWrapper {
    func registerUser(email: String, password: String, completion: @escaping (Result<(id: String, email: String?, name: String?), Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(.failure(error))
            }
            if let result = result {
                let user = result.user
                completion(.success((user.uid, user.email, user.displayName)))
            }
        }
    }
}

final class FirebaseGateway: AuthGateway {
    
    private let firebase: FirebaseWrapper
    
    init(firebase: FirebaseWrapper) {
        self.firebase = firebase
    }
    
    func register(email: String, username: String, password: String, completion: @escaping (Result<UserEntity, RegisterUserUseCase.Error>) -> Void) {
        
        firebase.registerUser(email: email, password: password) { (result) in
            switch result {
            case .failure(let error): return
            case .success(let user):
                let userEntity = UserEntity(id: user.id, email: user.email ?? "", username: user.name ?? "")
                completion(.success(userEntity))
            }
        }
        
    }
    
}
