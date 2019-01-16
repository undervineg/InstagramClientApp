//
//  LoginViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 11/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class LoginViewController: UIViewController {
    
    // MARK: Commands
    var login: ((String, String) -> Void)?
    
    // MARK: UI Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    // MARK: Router
    private var router: AuthRouter.Routes?
    
    // MARK: Initializer
    convenience init(router: AuthRouter.Routes) {
        self.init()
        self.router = router
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        changeButtonColor(false)
    }
    
    // MARK: Actions
    @IBAction func handleTextInputChange(_ sender: UITextField) {
        changeButtonColor(isAllTextFieldsValid())
    }
    
    @IBAction func login(_ sender: UIButton) {
        guard isAllTextFieldsValid() else { return }
        
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        indicatorView.startAnimating()
        login?(email, password)
    }
    
    @IBAction func routeToSignUpPage(_ sender: UIButton) {
        router?.openRegisterPage()
    }
    
    // MARK: Private Methods
    private func changeButtonColor(_ isAllTextFieldsValid: Bool) {
        let alpha: CGFloat = isAllTextFieldsValid ? 1 : 0.5
        loginButton.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 175/255, alpha: alpha)
        loginButton.isEnabled = isAllTextFieldsValid
    }
    
    private func isAllTextFieldsValid() -> Bool {
        let emailValid = emailTextField.text?.count ?? 0 > 0
        let passwordValid = passwordTextField.text?.count ?? 0 > 0
        
        return emailValid && passwordValid
    }
}

extension LoginViewController: LoginView {
    
    // MARK: Login View
    func displayMain() {
        indicatorView.stopAnimating()
        router?.openMainPage()
    }
}
