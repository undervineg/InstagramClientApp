//
//  RegistrationUseCase.swift
//  InstagramEngine
//
//  Created by 심승민 on 01/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public protocol RegisterUserClient {
    func register(email: String, username: String, password: String, profileImage: Data, completion: @escaping (RegisterUserUseCase.Error?) -> Void)
}

public protocol RegisterUserUseCaseOutput {
    func registerSucceeded()
    func registerFailed(_ error: RegisterUserUseCase.Error)
}

final public class RegisterUserUseCase {
    private let client: RegisterUserClient
    private let output: RegisterUserUseCaseOutput
    
    public init(client: RegisterUserClient, output: RegisterUserUseCaseOutput) {
        self.client = client
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
    
    public func register(email: String, username: String, password: String, profileImage: Data) {
        client.register(email: email, username: username, password: password, profileImage: profileImage) { (error) in
            if let error = error {
                self.output.registerFailed(error)
                return
            }
            self.output.registerSucceeded()
        }
    }
}
