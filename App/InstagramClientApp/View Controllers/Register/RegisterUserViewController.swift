//
//  RegisterUserViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 02/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

class RegisterUserViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    var register: ((String, String, String, @escaping (Result<UserEntity, RegisterUserUseCase.Error>) -> Void) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signUpButton.addTarget(self, action: #selector(signUp(_:)), for: .touchUpInside)
        emailTextField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
    }
    
    @objc private func handleTextInputChange(_ sender: UITextField) {
        let isEmailValid = emailTextField.text?.count ?? 0 > 0
        let isUsernameValid = usernameTextField.text?.count ?? 0 > 0
        let isPasswordValid = passwordTextField.text?.count ?? 0 > 0
        
        if isEmailValid && isUsernameValid && isPasswordValid {
            signUpButton.backgroundColor = UIColor(red: 123/255, green: 115/255, blue: 231/255, alpha: 1)
        } else {
            signUpButton.backgroundColor = UIColor(red: 123/255, green: 115/255, blue: 231/255, alpha: 0.5)
        }
    }
    
    @objc private func signUp(_ sender: UIButton) {
        guard let email = emailTextField.text, email.count > 0,
            let username = usernameTextField.text, username.count > 0,
            let password = passwordTextField.text, password.count > 0 else {
            return
        }
        register?(email, username, password) {
            print($0)
        }
    }

}
