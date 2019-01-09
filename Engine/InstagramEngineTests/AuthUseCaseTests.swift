//
//  AuthUseCaseTests.swift
//  InstagramEngineTests
//
//  Created by 심승민 on 10/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
@testable import InstagramEngine

class AuthUseCaseTests: XCTestCase {
    
    func test_checkIfAuthenticatedTwice_sendSuccessMessageTwice() {
        let client = StubClient()
        let output = StubAuthUseCaseOutput()
        let sut = AuthUseCase(client: client, output: output)
        
        sut.checkIfAuthenticated()
        sut.checkIfAuthenticated()
        
        client.completeWithSuccess(at: 0)
        client.completeWithSuccess(at: 1)
        
        XCTAssertEqual(output.succeededCallCount, 2)
        XCTAssertEqual(output.failedCallCount, 0)
    }
    
    func test_checkIfAuthenticatedTwice_sendFailureMessageTwice() {
        let client = StubClient()
        let output = StubAuthUseCaseOutput()
        let sut = AuthUseCase(client: client, output: output)
        
        sut.checkIfAuthenticated()
        sut.checkIfAuthenticated()
        
        client.completeWithFailure(at: 0)
        client.completeWithFailure(at: 1)
        
        XCTAssertEqual(output.succeededCallCount, 0)
        XCTAssertEqual(output.failedCallCount, 2)
    }

    
    // MARK: - Helpers
    
    private class StubClient: AuthClient {
        private var messages = [(Bool) -> Void]()
        
        func checkIfAuthenticated(_ completion: @escaping (Bool) -> Void) {
            messages.append(completion)
        }
        
        func completeWithSuccess(at index: Int = 0) {
            messages[index](true)
        }
        
        func completeWithFailure(at index: Int = 0) {
            messages[index](false)
        }
    }
    
    private class StubAuthUseCaseOutput: AuthUseCaseOutput {
        var succeededCallCount = 0
        var failedCallCount = 0
        
        func authSucceeded() {
            succeededCallCount += 1
        }
        
        func authFailed() {
            failedCallCount += 1
        }
    }
}
