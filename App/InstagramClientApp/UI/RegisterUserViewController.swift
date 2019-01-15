//
//  RegisterUserViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 02/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

final class RegisterUserViewController: UIViewController {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    private var router: AuthRouter.Routes?
    
    var register: ((String, String, String, Data) -> ())?
    
    convenience init(router: AuthRouter.Routes) {
        self.init()
        self.router = router
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIExtras()
    }
    
    @IBAction func openImagePicker(_ sender: UIButton) {
        openEditableImagePicker()
    }
    
    @IBAction func handleTextInputChange(_ sender: UITextField) {
        makeButtonEnableAndColored()
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        validateTextFieldsAndRegisterUser()
    }
    
    @IBAction func routeToLoginPage(_ sender: UIButton) {
        router?.openLoginPage()
    }
}

extension RegisterUserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let editedImage = info[.editedImage] as? UIImage
        profileImageButton.setImage(editedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension RegisterUserViewController: RegisterUserView {
    func displayMain() {
        indicatorView.stopAnimating()
        router?.openMainPage()
    }
    
    func display(_ errorMessage: String) {
        let alert = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true) {
            self.indicatorView.stopAnimating()
        }
    }
}

extension RegisterUserViewController {
    
    // MARK: - Private Methods
    
    private func isAllTextFieldsValid() -> Bool {
        let isEmailValid = emailTextField.text?.count ?? 0 > 0
        let isUsernameValid = usernameTextField.text?.count ?? 0 > 0
        let isPasswordValid = passwordTextField.text?.count ?? 0 > 0
        
        return isEmailValid && isUsernameValid && isPasswordValid
    }
    
    private func validateTextFieldsAndRegisterUser() {
        guard isAllTextFieldsValid() else { return }
        
        let email = emailTextField.text ?? ""
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let profileImageData = profileImageButton.imageView?.image?.jpegData(compressionQuality: 0.3)
        
        indicatorView.startAnimating()
        register?(email, username, password, profileImageData!)
    }
    
    private func openEditableImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func makeButtonEnableAndColored() {
        let alpha: CGFloat = isAllTextFieldsValid() ? 1 : 0.5
        signUpButton.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 175/255, alpha: alpha)
        signUpButton.isEnabled = isAllTextFieldsValid()
    }
    
    private func configureUIExtras() {
        profileImageButton.layer.cornerRadius = profileImageButton.frame.width/2
        profileImageButton.layer.masksToBounds = true
        
        signUpButton.isEnabled = false
        signUpButton.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 175/255, alpha: 0.5)
        
        navigationController?.isNavigationBarHidden = true
    }
}
