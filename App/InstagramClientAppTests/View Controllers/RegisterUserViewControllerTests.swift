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
        let sut = makeSUT()
        
        XCTAssertEqual(sut.emailTextField.placeholder, "Email")
        XCTAssertEqual(sut.usernameTextField.placeholder, "Username")
        XCTAssertEqual(sut.passwordTextField.placeholder, "Password")
    }
    
    func test_viewDidLoad_passwordTextFieldIsSecureTextEntry() {
        let sut = makeSUT()
        
        XCTAssertTrue(sut.passwordTextField.isSecureTextEntry)
    }
    
    func test_viewDidLoad_rendersSignUpButtonTitleLabel() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.signUpButton.titleLabel?.text, "Sign Up")
    }
    
    func test_viewDidLoad_disablesSignUpButton() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.signUpButton.isEnabled, false)
    }
    
    func test_viewDidLoad_weakenSignUpButtonBackgroundColor() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.signUpButton.backgroundColor, UIColor(red: 123/255, green: 115/255, blue: 231/255, alpha: 0.5))
    }

    func test_clickSignUpButton_doNotSendMessageWhenEmptyTextExist() {
        let useCaseStub = RegisterUseCaseStub()
        let sut = makeSUT(useCaseStub.register)
        
        sut.emailTextField.text = ""
        sut.usernameTextField.text = ""
        sut.passwordTextField.text = ""
        
        sut.signUpButton.sendActions(for: .touchUpInside)
        
        XCTAssert(useCaseStub.callbackWasFired == false)
    }
    
    func test_clickSignUpButton_sendMessageWhenTextExist() {
        let useCaseStub = RegisterUseCaseStub()
        let sut = makeSUT(useCaseStub.register)
        
        sut.emailTextField.text = "test@email.com"
        sut.usernameTextField.text = "tester"
        sut.passwordTextField.text = "1234"
        
        sut.signUpButton.sendActions(for: .touchUpInside)
        
        XCTAssert(useCaseStub.callbackWasFired == true)
    }
    
    func test_clickSignUpButton_backgroundColorThicken_whenAllTextFieldsAreFilled() {
        let sut = makeSUT()
        
        sut.emailTextField.text = "test@email.com"
        sut.emailTextField.sendActions(for: .editingChanged)
        sut.usernameTextField.text = "tester"
        sut.usernameTextField.sendActions(for: .editingChanged)
        sut.passwordTextField.text = "1234"
        sut.passwordTextField.sendActions(for: .editingChanged)
        
        XCTAssertEqual(sut.signUpButton.backgroundColor, UIColor(red: 123/255, green: 115/255, blue: 231/255, alpha: 1))
        XCTAssertEqual(sut.signUpButton.isEnabled, true)
    }
    
    func test_clickSignUpButton_backgroundColorWeaken_ifOneTextFieldIsEmpty() {
        let sut = makeSUT()
        
        sut.emailTextField.text = ""
        sut.emailTextField.sendActions(for: .editingChanged)
        sut.usernameTextField.text = "tester"
        sut.usernameTextField.sendActions(for: .editingChanged)
        sut.passwordTextField.text = "1234"
        sut.passwordTextField.sendActions(for: .editingChanged)
        
        XCTAssertEqual(sut.signUpButton.backgroundColor, UIColor(red: 123/255, green: 115/255, blue: 231/255, alpha: 0.5))
        XCTAssertEqual(sut.signUpButton.isEnabled, false)
    }
    
    func test_clickProfileButton_opensUIImagePickerController() {
        let sut = makeSUT()
        
        sut.profileImageButton.sendActions(for: .touchUpInside)
        
//        XCTAssert()
    }
    
    // MARK: - Helpers
    
    private func makeSUT(_ callback: ((String, String, String, @escaping (Result<UserEntity, RegisterUserUseCase.Error>) -> Void) -> ())? = nil) -> RegisterUserViewController {
        var sut: RegisterUserViewController?
        if let callback = callback {
            sut = RegisterUserViewController(registerCallback: callback)
        } else {
            sut = RegisterUserViewController()
        }
        _ = sut?.view
        return sut ?? RegisterUserViewController()
    }
    
    private class RegisterUseCaseStub {
        var callbackWasFired = false
        
        func register(email: String, username: String, password: String, completion: @escaping (Result<UserEntity, RegisterUserUseCase.Error>) -> Void) {
            callbackWasFired = true
        }
    }
}
