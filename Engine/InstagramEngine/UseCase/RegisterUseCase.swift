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
        case emailAlreadyInUse
        case invalidEmail
        case accountExistsWithDifferentCredential
        case networkError
        case credentialAlreadyInUse
        case databaseUpdateError
        case storageUploadError
        case unknown
        
        public var localizedDescription: String {
            switch self {
            case .invalidName: return "이름이 유효하지 않습니다."
            case .invalidPassword: return "비밀번호가 유효하지 않습니다."
            case .emailAlreadyInUse: return "이메일이 이미 사용중입니다. 다시 입력해주세요."
            case .invalidEmail: return "이메일이 유효하지 않습니다."
            case .accountExistsWithDifferentCredential: return "계정이 이미 존재합니다."
            case .networkError: return "네트워크 오류 발생"
            case .credentialAlreadyInUse: return "계정이 이미 사용중입니다."
            case .databaseUpdateError: return "데이터베이스 오류 발생"
            case .storageUploadError: return "이미지 업로드 오류 발생"
            default: return "알 수 없는 오류 발생"
            }
        }
    }
    
    public func register(email: String, username: String, password: String, profileImage: Data) {
        client.register(email: email, username: username, password: password, profileImage: profileImage) { [weak self] (error) in
            if let error = error {
                self?.output.registerFailed(error)
            } else {
                self?.output.registerSucceeded()
            }
        }
    }
}
