//
//  LoginUseCase.swift
//  InstagramEngine
//
//  Created by 심승민 on 13/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

public protocol LoginClient {
    func login(email: String, password: String, completion: @escaping (LoginUseCase.Error?) -> Void)
}

public protocol LoginUseCaseOutput {
    func loginSucceeded()
    func loginFailed(_ error: LoginUseCase.Error)
}

final public class LoginUseCase {
    private let client: LoginClient
    private let output: LoginUseCaseOutput
    
    public init(client: LoginClient, output: LoginUseCaseOutput) {
        self.client = client
        self.output = output
    }
    
    public enum Error: Swift.Error {
        case invalidEmail
        case invalidPassword
        case userDisabled
        case wrongPassword
        case userNotFound
        case networkError
        case unknown
        
        public var localizedDescription: String {
            switch self {
            case .invalidEmail: return "이메일이 유효하지 않습니다."
            case .wrongPassword: return "비밀번호를 다시 입력해주세요."
            case .userDisabled: return "해당 사용자는 블록되었습니다."
            case .userNotFound: return "사용자를 찾을 수 없습니다."
            case .networkError: return "네트워크 오류 발생"
            default: return "알 수 없는 오류 발생"
            }
        }
    }
    
    public func login(email: String, password: String) {
        client.login(email: email, password: password) { [weak self] (error) in
            if let error = error {
                self?.output.loginFailed(error)
                return
            }
            self?.output.loginSucceeded()
        }
    }
}
