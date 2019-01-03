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
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    convenience init(registerCallback: @escaping (String, String, String, @escaping (Result<UserEntity, RegisterUserUseCase.Error>) -> Void) -> ()) {
        self.init()
        
        self.registerCallback = registerCallback
    }
    
    private(set) var registerCallback: ((String, String, String, @escaping (Result<UserEntity, RegisterUserUseCase.Error>) -> Void) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signUpButton.isEnabled = false
        signUpButton.backgroundColor = UIColor(red: 123/255, green: 115/255, blue: 231/255, alpha: 0.5)
        
        profileImageButton.addTarget(self, action: #selector(openImagePicker(_:)), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUp(_:)), for: .touchUpInside)
        emailTextField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
    }
    
    @objc private func openImagePicker(_ sender: UIButton) {
        
    }
    
    @objc private func handleTextInputChange(_ sender: UITextField) {
        let isEmailValid = emailTextField.text?.count ?? 0 > 0
        let isUsernameValid = usernameTextField.text?.count ?? 0 > 0
        let isPasswordValid = passwordTextField.text?.count ?? 0 > 0
        
        if isEmailValid && isUsernameValid && isPasswordValid {
            signUpButton.backgroundColor = UIColor(red: 123/255, green: 115/255, blue: 231/255, alpha: 1)
            signUpButton.isEnabled = true
        } else {
            signUpButton.backgroundColor = UIColor(red: 123/255, green: 115/255, blue: 231/255, alpha: 0.5)
            signUpButton.isEnabled = false
        }
    }
    
    @objc private func signUp(_ sender: UIButton) {
        guard let email = emailTextField.text, email.count > 0,
            let username = usernameTextField.text, username.count > 0,
            let password = passwordTextField.text, password.count > 0 else {
            return
        }
        registerCallback?(email, username, password) {
            print($0)
        }
    }

}
