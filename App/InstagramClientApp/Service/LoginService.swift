//
//  LoginService.swift
//  InstagramClientApp
//
//  Created by 심승민 on 13/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import FirebaseAuth
import InstagramEngine

final class LoginService: LoginClient {
    private let auth: FirebaseAuthWrapper.Type
    
    init(auth: FirebaseAuthWrapper.Type) {
        self.auth = auth
    }
    
    func login(email: String, password: String, completion: @escaping (LoginUseCase.Error?) -> Void) {
        auth.login(email: email, password: password) { (error) in
            if let error = error {
                let loginError = self.mapErrorCode(with: error._code)
                completion(loginError)
                return
            }
            completion(nil)
        }
    }
    
    private func mapErrorCode(with errorCode: Int) -> LoginUseCase.Error {
        if let authError = AuthErrorCode(rawValue: errorCode) {
            switch authError {
            case .invalidEmail: return .invalidEmail
            case .wrongPassword: return .wrongPassword
            case .userDisabled: return .userDisabled
            case .userNotFound: return .userNotFound
            case .networkError: return .networkError
            default: return .unknown
            }
        }
        return .unknown
    }
}
