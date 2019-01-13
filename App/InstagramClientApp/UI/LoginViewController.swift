//
//  LoginViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 11/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    private var router: (LoginRouter.Routes & Closable)?
    
    var login: ((String, String) -> Void)?
    
    convenience init(router: LoginRouter.Routes & Closable) {
        self.init()
        self.router = router
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func handleTextInputChange(_ sender: UITextField) {
        loginButton.backgroundColor = isAllTextFieldsValid() ? UIColor(red: 123/255, green: 115/255, blue: 231/255, alpha: 1) : UIColor(red: 123/255, green: 115/255, blue: 231/255, alpha: 0.5)
        loginButton.isEnabled = isAllTextFieldsValid()
    }
    
    @IBAction func login(_ sender: UIButton) {
        guard isAllTextFieldsValid() else { return }
        
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        login?(email, password)
    }
    
    @IBAction func routeToSignUpPage(_ sender: UIButton) {
        if let navigation = navigationController, navigation.children.count > 1 {
            router?.close(to: nil)
        } else {
            router?.openRegisterPage()
        }
    }
    
    // MARK: - Private Methods
    private func isAllTextFieldsValid() -> Bool {
        let emailValid = emailTextField.text?.count ?? 0 > 0
        let passwordValid = passwordTextField.text?.count ?? 0 > 0
        
        return emailValid && passwordValid
    }
}

extension LoginViewController: LoginView {
    func displayMain() {
        router?.openMainPage()
    }
    
    func displayError(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true) {
            // stop indicatorView
        }
    }
}
