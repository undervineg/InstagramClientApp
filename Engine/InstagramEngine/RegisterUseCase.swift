//
//  RegistrationUseCase.swift
//  InstagramEngine
//
//  Created by 심승민 on 01/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

enum RegisterClientResult {
    case success(User)
    case failure(Error)
}

protocol RegisterClient {
    func register(user: User, completion: @escaping (RegisterClientResult) -> Void)
}
