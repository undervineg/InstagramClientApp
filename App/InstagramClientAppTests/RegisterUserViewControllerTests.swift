//
//  RegisterUserViewControllerTests.swift
//  InstagramClientAppTests
//
//  Created by 심승민 on 01/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
import Firebase
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

}
