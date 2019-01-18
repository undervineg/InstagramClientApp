//
//  AuthClientAdapter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 10/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation
import InstagramEngine

final class AuthService: AuthClient {
    
    private let auth: FirebaseAuthWrapper.Type
    
    init(auth: FirebaseAuthWrapper.Type) {
        self.auth = auth
    }
    
    func checkIfAuthenticated(_ completion: @escaping (Bool) -> Void) {
        completion(auth.isAuthenticated)
    }
}
