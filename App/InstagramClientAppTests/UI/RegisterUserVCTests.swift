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
    
    func test_viewDidLoad_profileImageButton_isRound() {
        let (sut, _, _) = makeSUT()
       
        XCTAssertEqual(sut.profileImageButton.layer.masksToBounds, true)
        XCTAssertEqual(sut.profileImageButton.layer.cornerRadius, sut.profileImageButton.frame.width/2)
    }
    
    func test_viewDidLoad_rendersTextFieldsPlaceholders() {
        let (sut, _, _) = makeSUT()
        
        XCTAssertEqual(sut.emailTextField.placeholder, "Email")
        XCTAssertEqual(sut.usernameTextField.placeholder, "Username")
        XCTAssertEqual(sut.passwordTextField.placeholder, "Password")
    }
    
    func test_viewDidLoad_passwordTextFieldIsSecureTextEntry() {
        let (sut, _, _) = makeSUT()
        
        XCTAssertTrue(sut.passwordTextField.isSecureTextEntry)
    }
    
    func test_viewDidLoad_rendersSignUpButtonTitleLabel() {
        let (sut, _, _) = makeSUT()
        
        XCTAssertEqual(sut.signUpButton.titleLabel?.text, "Sign Up")
    }
    
    func test_viewDidLoad_disablesSignUpButton() {
        let (sut, _, _) = makeSUT()
        
        XCTAssertEqual(sut.signUpButton.isEnabled, false)
    }
    
    func test_viewDidLoad_weakenSignUpButtonBackgroundColor() {
        let (sut, _, _) = makeSUT()
        
        XCTAssertEqual(sut.signUpButton.backgroundColor, UIColor(red: 123/255, green: 115/255, blue: 231/255, alpha: 0.5))
    }

    func test_clickSignUpButton_doNotSendMessageWhenEmptyTextExist() {
        let (sut, _, useCaseStub) = makeSUT()
        
        sut.emailTextField.text = ""
        sut.usernameTextField.text = "tester"
        sut.passwordTextField.text = "1234"
        
        sut.signUpButton.sendActions(for: .touchUpInside)
        
        XCTAssertEqual(useCaseStub.registerCallCount, 0)
    }
    
    func test_clickSignUpButton_sendMessageWhenTextExist() {
        let (sut, _, useCaseStub) = makeSUT()
        
        sut.emailTextField.text = "test@email.com"
        sut.usernameTextField.text = "tester"
        sut.passwordTextField.text = "1234"
        
        sut.signUpButton.sendActions(for: .touchUpInside)
        
        XCTAssertEqual(useCaseStub.registerCallCount, 1)
    }
    
    func test_clickSignUpButton_backgroundColorThicken_whenAllTextFieldsAreFilled() {
        let (sut, _, _) = makeSUT()
        
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
        let (sut, _, _) = makeSUT()
        
        sut.emailTextField.text = ""
        sut.emailTextField.sendActions(for: .editingChanged)
        sut.usernameTextField.text = "tester"
        sut.usernameTextField.sendActions(for: .editingChanged)
        sut.passwordTextField.text = "1234"
        sut.passwordTextField.sendActions(for: .editingChanged)
        
        XCTAssertEqual(sut.signUpButton.backgroundColor, UIColor(red: 123/255, green: 115/255, blue: 231/255, alpha: 0.5))
        XCTAssertEqual(sut.signUpButton.isEnabled, false)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: RegisterUserViewController, router: StubRegisterRouter, useCase: StubRegisterUseCase) {
        let router = StubRegisterRouter()
        let useCaseStub = StubRegisterUseCase()
        let sut = RegisterUserViewController(router: router)
        sut.register = useCaseStub.register
        _ = sut.view
        return (sut, router, useCaseStub)
    }
    
    private class StubRegisterUseCase {
        var registerCallCount = 0
        
        func register(email: String, username: String, password: String, profileImage: Data) {
            registerCallCount += 1
        }
    }
    
    private class StubRegisterRouter: AuthRouter.Routes, Closable {
        var loginPageIsOpened: Bool = false
        var registerPageIsOpened: Bool = false
        var closed: Bool = false
        
        init() {}
        
        var loginTransition: Transition = PushTransition()
        var registerTransition: Transition = PushTransition()
        
        
        func openLoginPage() {
            loginPageIsOpened = true
        }
        
        func openRegisterPage() {
            registerPageIsOpened = true
        }
        
        func close() {
            closed = true
        }
        
        func close(to destVC: UIViewController) {
            closed = true
        }
    }
}
