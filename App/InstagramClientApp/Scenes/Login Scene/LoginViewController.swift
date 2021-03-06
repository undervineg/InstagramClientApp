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
    private var router: LoginRouter.Routes?
    
    // MARK: Initializer
    convenience init(router: LoginRouter.Routes) {
        self.init()
        self.router = router
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUIExtras()
    }
    
    // MARK: Actions
    @IBAction func handleTextInputChange(_ sender: UITextField) {
        loginButton.enableButtonWithColor(isAllTextFieldsValid())
    }
    
    @IBAction func login(_ sender: UIButton) {
        guard isAllTextFieldsValid() else { return }
        
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        view.endEditing(true)
        startIndicatorAnimating()
        login?(email, password)
    }
    
    @IBAction func routeToSignUpPage(_ sender: UIButton) {
        router?.openRegisterPage()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension LoginViewController: LoginView {
    // MARK: Login View
    func displayMain() {
        stopIndicatorAnimating()
        router?.openMainPage()
    }
    
    func displayError(_ errorMessage: String) {
        let alert = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
            self?.stopIndicatorAnimating()
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension LoginViewController {
    // MARK: Private Methods
    private func isAllTextFieldsValid() -> Bool {
        return [emailTextField, passwordTextField].isAllValid(shouldCheckBlanksAt: nil)
    }
    
    private func configureUIExtras() {
        navigationController?.isNavigationBarHidden = true
        
        loginButton.layer.cornerRadius = 5
        loginButton.layer.masksToBounds = true
        loginButton.enableButtonWithColor(false)
    }
    
    private func startIndicatorAnimating() {
        loginButton.setTitleColor(.clear, for: .normal)
        indicatorView.startAnimating()
    }
    
    private func stopIndicatorAnimating() {
        loginButton.setTitleColor(.white, for: .normal)
        indicatorView.stopAnimating()
    }
}
