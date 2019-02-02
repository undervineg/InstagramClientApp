//
//  LoginService.swift
//  InstagramClientApp
//
//  Created by 심승민 on 13/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import FirebaseAuth
import FirebaseDatabase
import InstagramEngine

final class LoginService: LoginClient {
    private let auth: FirebaseAuthWrapper.Type
    private let tokenService: TokenService
    
    init(auth: FirebaseAuthWrapper.Type) {
        self.auth = auth
        self.tokenService = TokenService(auth: Auth.self, database: Database.self)
    }
    
    func logout(_ completion: @escaping (Error?) -> Void) {
        tokenService.invalidateFcmToken()
        auth.logout(completion)
    }
    
    func login(email: String, password: String, completion: @escaping (LoginUseCase.Error?) -> Void) {
        auth.login(email: email, password: password) { (error) in
            if let error = error {
                let loginError = self.mapErrorCode(with: error._code)
                completion(loginError)
                return
            }
            self.tokenService.refreshFcmToken()
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
