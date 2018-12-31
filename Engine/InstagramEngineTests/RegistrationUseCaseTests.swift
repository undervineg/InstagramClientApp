//
//  RegistrationUseCaseTests.swift
//  InstagramEngineTests
//
//  Created by 심승민 on 01/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
@testable import InstagramEngine

class RegistrationUseCaseTests: XCTestCase {

    func test_init_doesNotRequestRegister() {
        let client = RegisterClientSpy()
        let _ = RegisterUseCase(client: client)
        
        XCTAssert(client.requestedUsers.isEmpty)
    }
    
    private class RegisterClientSpy: RegisterClient {
        private var messages = [(user: User, completion: (RegisterClientResult) -> Void)]()
        
        var requestedUsers: [User] {
            return messages.map { $0.user }
        }
        
        func register(user: User, completion: @escaping (RegisterClientResult) -> Void) {
            
        }
    }
}
