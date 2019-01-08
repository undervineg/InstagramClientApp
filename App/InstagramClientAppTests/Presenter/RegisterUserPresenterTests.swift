//
//  RegisterUserPresenterTests.swift
//  InstagramClientAppTests
//
//  Created by 심승민 on 08/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
import InstagramEngine
@testable import InstagramClientApp

class RegisterUserPresenterTests: XCTestCase {

    func test_deliversTheRightErrorMessage_whenRegisterFailed() {
        let view = RegisterUserViewStub()
        let presenter = RegisterUserPresenter(view: view)
        
        let errors = [
            RegisterUserUseCase.Error.accountExistsWithDifferentCredential,
            .credentialAlreadyInUse,
            .databaseUpdateError,
            .emailAlreadyInUse,
            .invalidEmail,
            .invalidName,
            .invalidPassword,
            .networkError,
            .storageUploadError,
            .unknown,
            .userDisabled,
            .userNotFound,
            .wrongPassword
        ]
        
        errors.forEach {
            presenter.registerFailed($0)
        }
        
        XCTAssertEqual(view.stubbedErrorMessages, errors.map { $0.localizedDescription })
    }
    
    func test_displayMain_whenRegisterSucceeded() {
        let view = RegisterUserViewStub()
        let presenter = RegisterUserPresenter(view: view)
        
        presenter.registerSucceeded()
        
        XCTAssertEqual(view.didMoveMain, true)
    }

    
    // MARK: - Helpers
    
    private class RegisterUserViewStub: RegisterUserView {
        var stubbedErrorMessages = [String]()
        var didMoveMain = false
        
        func display(_ errorMessage: String) {
            stubbedErrorMessages.append(errorMessage)
        }
        
        func displayMain() {
            didMoveMain = true
        }
    }
}
