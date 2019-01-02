//
//  FirebaseGatewayTests.swift
//  InstagramClientAppTests
//
//  Created by 심승민 on 02/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
import InstagramEngine
import Firebase
@testable import InstagramClientApp

/*
 * Role: Register user to firebase
 */
class FirebaseGatewayTests: XCTestCase {
    
    func test_register_deliversTheRightCurrentUser() {
        let (sut, firebase) = makeSUT()
        
        var capturedUser = [UserEntity]()
        sut.register(email: "dummy@email.com", username: "dummy", password: "1234") {
            if case let Result.success(user) = $0 {
                capturedUser.append(user)
            }
        }
        
        firebase.completeWithSuccess(id: "0", name: "dummy")
        
        let user = UserEntity(id: "0", email: "dummy@email.com", username: "dummy")
        XCTAssertEqual(capturedUser.count, 1)
        XCTAssertEqual(capturedUser, [user])
    }
    
    func test_registerTwice_deliversTheRightCurrentUserTwice() {
        let (sut, firebase) = makeSUT()

        var capturedUser = [UserEntity]()
        sut.register(email: "dummy@email.com", username: "dummy", password: "1234") {
            if case let Result.success(user) = $0 {
                capturedUser.append(user)
            }
        }
        sut.register(email: "dummy2@email.com", username: "dummy2", password: "1234") {
            if case let Result.success(user) = $0 {
                capturedUser.append(user)
            }
        }
        
        firebase.completeWithSuccess(id: "0", name: "dummy", at: 0)
        firebase.completeWithSuccess(id: "1", name: "dummy2", at: 1)
        
        
        let user1 = UserEntity(id: "0", email: "dummy@email.com", username: "dummy")
        let user2 = UserEntity(id: "1", email: "dummy2@email.com", username: "dummy2")
        XCTAssertEqual(capturedUser.count, 2)
        XCTAssertEqual(capturedUser, [user1, user2])
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: FirebaseGateway, firebase: MockFirebase) {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        let firebase = MockFirebase()
        let sut = FirebaseGateway(firebase: firebase)
        
        return (sut, firebase)
    }
    
    // Auth를 상속받아서 메소드를 오버라이드 할 수도 있지만, extension에서 정의한 메소드는 오버라이드하지 못 한다. 따라서 프로토콜로 대체
    private class MockFirebase: FirebaseWrapper {
        private var messages = [(email: String, pw: String, completed: (Result<(id: String, email: String?, name: String?), Error>) -> Void)]()
        
        private var capturedEmail: [String] {
            return messages.map { $0.email }
        }
        
        func registerUser(email: String, password: String, completion: @escaping (Result<(id: String, email: String?, name: String?), Error>) -> Void) {
            messages.append((email, password, completion))
        }
        
        func completeWithSuccess(id: String, name: String, at index: Int = 0) {
            messages[index].completed(.success((id: id, email: capturedEmail[index], name: name)))
        }
    }
}
