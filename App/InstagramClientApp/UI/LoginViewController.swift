//
//  LoginViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 11/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    private var router: AuthRouter.Routes?
    
    var login: ((String, String) -> Void)?
    
    convenience init(router: AuthRouter.Routes) {
        self.init()
        self.router = router
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        changeButtonColor(false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func handleTextInputChange(_ sender: UITextField) {
        changeButtonColor(isAllTextFieldsValid())
    }
    
    private func changeButtonColor(_ isAllTextFieldsValid: Bool) {
        let alpha: CGFloat = isAllTextFieldsValid ? 1 : 0.5
        loginButton.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 175/255, alpha: alpha)
        loginButton.isEnabled = isAllTextFieldsValid
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
    
    // MARK: - Private Methods
    private func isAllTextFieldsValid() -> Bool {
        let emailValid = emailTextField.text?.count ?? 0 > 0
        let passwordValid = passwordTextField.text?.count ?? 0 > 0
        
        return emailValid && passwordValid
    }
}

extension LoginViewController: LoginView {
    func displayMain() {
        indicatorView.stopAnimating()
        router?.openMainPage()
    }

}
