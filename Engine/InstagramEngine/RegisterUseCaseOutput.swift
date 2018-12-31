//
//  RegistrationUseCaseOutput.swift
//  InstagramEngine
//
//  Created by 심승민 on 01/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

protocol RegisterUseCaseOutput {
    func registerSucceeded(user: User)
    func registerFailed(error: Error)
}
