//
//  RegisterUserUseCaseTests.swift
//  InstagramEngineTests
//
//  Created by 심승민 on 01/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
@testable import InstagramEngine

class RegisterUserUseCase {
    private let gateway: AuthGateway
    
    init(gateway: AuthGateway) {
        self.gateway = gateway
    }
    
    func register(email: String, username: String, password: String) {
        
    }
}

/*
 * SUT: RegisterUserUseCase
 * Dependencies: RegisterUserGateway, RegisterUserUseCaseOutput
 */
class RegisterUserUseCaseTests: XCTestCase {

    func test_init_doesNotRequestRegister() {
        let gateway = AuthGatewaySpy()
        
        let _ = RegisterUserUseCase.init(gateway: gateway)
        
        XCTAssert(gateway.requestedUsers.isEmpty)
    }
    
    
    // MARK: - Helpers
    
    private class AuthGatewaySpy: AuthGateway {
        var requestedUserInfos = [UserInfo]()
        
        func register(email: String, username: String, password: String, completion: @escaping (Result) -> Void) {
            
        }
    }
    
    private struct UserInfo: Equatable {
        let email: String
        let username: String
        let password: String
    }

}
