//
//  RegistrationUseCase.swift
//  InstagramEngine
//
//  Created by 심승민 on 01/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

enum Result {
    case success
    case failure
}

protocol AuthGateway {
    func register(email: String, username: String, password: String, completion: @escaping (Result) -> Void)
}

