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

protocol RegisterUserUseCaseOutput {
    func registerSucceeded(_ user: UserEntity)
    func registerFailed(_ error: RegisterUserUseCase.Error)
}

final public class RegisterUserUseCase {
    private let gateway: AuthGateway
    private let output: RegisterUserUseCaseOutput
    
    init(gateway: AuthGateway, output: RegisterUserUseCaseOutput) {
        self.gateway = gateway
        self.output = output
    }
    
    public enum Error: Swift.Error {
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
    
    public func register(email: String, username: String, password: String, completion: @escaping (Error) -> Void) {
        gateway.register(email: email, username: username, password: password) { (result) in
            switch result {
            case .success: break
            case .failure: completion(.invalidName)
            }
        }
    }
}