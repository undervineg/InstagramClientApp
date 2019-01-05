//
//  RegistrationUseCase.swift
//  InstagramEngine
//
//  Created by 심승민 on 01/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public enum Result<T, E> {
    case success(T)
    case failure(E)
}

public protocol AuthGateway {
    func fetchCurrentUserInfo() -> UserEntity?
    func register(email: String, username: String, password: String, profileImage: Data, completion: @escaping (RegisterUserUseCase.Error?) -> Void)
}

public protocol RegisterUserUseCaseOutput {
    func registerSucceeded()
    func registerFailed(_ error: RegisterUserUseCase.Error)
}

final public class RegisterUserUseCase {
    private let gateway: AuthGateway
    private let output: RegisterUserUseCaseOutput
    
    public init(gateway: AuthGateway, output: RegisterUserUseCaseOutput) {
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
        case databaseUpdateError
        case storageUploadError
        case unknown
    }
    
    public func register(email: String, username: String, password: String, profileImage: Data, completion: @escaping (RegisterUserUseCase.Error?) -> Void) {
        gateway.register(email: email, username: username, password: password, profileImage: profileImage) { (error) in
            if let error = error {
                completion(error)
            }
        }
    }
}
