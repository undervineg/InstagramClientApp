//
//  RegisterUserViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 02/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

class RegisterUserViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    var register: ((String, String, String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signUpButton.addTarget(self, action: #selector(signUp(_:)), for: .touchUpInside)
    }
    
    @objc private func signUp(_ sender: UIButton) {
        guard let email = emailTextField.text,
            let username = usernameTextField.text,
            let password = passwordTextField.text else {
            return
        }
        register?(email, username, password)
    }

}
