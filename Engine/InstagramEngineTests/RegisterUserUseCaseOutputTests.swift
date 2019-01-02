//
//  RegisterUserUseCaseOutputTests.swift
//  InstagramEngineTests
//
//  Created by 심승민 on 01/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
@testable import InstagramEngine

class RegisterUserUseCaseOutputTests: XCTestCase {

    func test() {
        let sut = RegisterUserPresenter()
        
        sut.registerSucceeded(UserEntity(id: "", email: "", username: "", password: ""))
        
        
    }
    
}
