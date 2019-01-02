//
//  RegisterUserViewControllerTests.swift
//  InstagramClientAppTests
//
//  Created by 심승민 on 01/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
import Firebase
import InstagramEngine
@testable import InstagramClientApp

class RegisterUserViewControllerTests: XCTestCase {

    func test_viewDidLoad_rendersTextFieldsPlaceholders() {
        let sut = RegisterUserViewController()
        
        _ = sut.view
        
        XCTAssertEqual(sut.emailTextField.placeholder, "Email")
        XCTAssertEqual(sut.usernameTextField.placeholder, "Username")
        XCTAssertEqual(sut.passwordTextField.placeholder, "Password")
    }
    
    func test_viewDidLoad_passwordTextFieldIsSecureTextEntry() {
        let sut = RegisterUserViewController()
        
        _ = sut.view
        
        XCTAssertTrue(sut.passwordTextField.isSecureTextEntry)
    }
    
    func test_viewDidLoad_rendersSignUpButtonTitleLabel() {
        let sut = RegisterUserViewController()
        
        _ = sut.view
        
        XCTAssertEqual(sut.signUpButton.titleLabel?.text, "Sign Up")
    }

    func test_clickSignUpButton_doNotSendMessageWhenEmptyTextExist() {
        let sut = RegisterUserViewController()
        let useCaseStub = RegisterUseCaseStub()
        sut.register = useCaseStub.register
        _ = sut.view
        
        sut.emailTextField.text = ""
        sut.usernameTextField.text = ""
        sut.passwordTextField.text = ""
        
        sut.signUpButton.sendActions(for: .touchUpInside)
        
        XCTAssert(useCaseStub.callbackWasFired == false)
    }
    
    func test_clickSignUpButton_sendMessageWhenTextExist() {
        let sut = RegisterUserViewController()
        let useCaseStub = RegisterUseCaseStub()
        sut.register = useCaseStub.register
        _ = sut.view
        
        sut.emailTextField.text = "test@email.com"
        sut.usernameTextField.text = "tester"
        sut.passwordTextField.text = "1234"
        
        sut.signUpButton.sendActions(for: .touchUpInside)
        
        XCTAssert(useCaseStub.callbackWasFired == true)
    }
    
    func test_clickSignUpButton_backgroundColorThicken() {
        let sut = RegisterUserViewController()
        _ = sut.view
        
        sut.emailTextField.text = "test@email.com"
        sut.emailTextField.sendActions(for: .editingChanged)
        sut.usernameTextField.text = "tester"
        sut.usernameTextField.sendActions(for: .editingChanged)
        sut.passwordTextField.text = "1234"
        sut.passwordTextField.sendActions(for: .editingChanged)
        
        XCTAssertEqual(sut.signUpButton.backgroundColor, UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1))
    }
    
    
    // MARK: - Helpers
    
    private class RegisterUseCaseStub {
        var callbackWasFired = false
        
        func register(email: String, username: String, password: String, completion: @escaping (Result<UserEntity, RegisterUserUseCase.Error>) -> Void) {
            callbackWasFired = true
        }
    }
}
