//
//  RegistrationUseCase.swift
//  InstagramEngine
//
//  Created by 심승민 on 01/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

enum Result<T, E> {
    case success(T)
    case failure(E)
}

protocol AuthGateway {
    func register(email: String, username: String, password: String, completion: @escaping (Result<UserEntity, Error>) -> Void)
}

class RegisterUserUseCase {
    private let gateway: AuthGateway
    
    init(gateway: AuthGateway) {
        self.gateway = gateway
    }
    
    enum Error: Swift.Error {
        case invalidName
        case invalidPassword
        case userDisabled
        case emailAlreadyInUse
        case invalidEmail
        case wrongPassword
        case userNotFound
        case accountExistsWithDifferentCredential
        case networkError
        case credentialAlreadyInUse
        case unknown
    }
    
    func register(email: String, username: String, password: String, completion: (Error) -> Void) {
        gateway.register(email: email, username: username, password: password) { (result) in
            
        }
    }
}
