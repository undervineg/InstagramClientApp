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
    
    // MARK: Commands
    var register: ((String, String, String, Data) -> ())?
    
    // MARK: UI Properites
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    // MAKR: Router
    private var router: RegisterRouter.Routes?
    
    // MARK: Initializer
    convenience init(router: RegisterRouter.Routes) {
        self.init()
        self.router = router
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIExtras()
    }
    
    // MARK: Actions
    @IBAction func openImagePicker(_ sender: UIButton) {
        openEditableImagePicker()
    }
    
    @IBAction func handleTextInputChange(_ sender: UITextField) {
        signUpButton.enableButtonWithColor(isAllTextFieldsValid())
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        validateTextFieldsAndRegisterUser()
    }
    
    @IBAction func routeToLoginPage(_ sender: UIButton) {
        router?.openLoginPage()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension RegisterUserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: Image Picker Delegate
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
    
    // MARK: RegisterUserView
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

extension RegisterUserViewController {
    
    // MARK: Private Methods
    private func isAllTextFieldsValid() -> Bool {
        return [emailTextField, usernameTextField, passwordTextField].isAllValid()
    }
    
    private func validateTextFieldsAndRegisterUser() {
        guard isAllTextFieldsValid() else { return }
        
        let email = emailTextField.text ?? ""
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let profileImageData = profileImageButton.imageView?.image?.jpegData(compressionQuality: 0.3)
        
        view.endEditing(true)
        startIndicatorAnimating()
        register?(email, username, password, profileImageData!)
    }
    
    private func openEditableImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func configureUIExtras() {
        profileImageButton.layer.cornerRadius = profileImageButton.frame.width/2
        profileImageButton.layer.masksToBounds = true
        
        profileImageButton.imageView?.contentMode = .scaleAspectFill
        profileImageButton.imageView?.clipsToBounds = true
        
        signUpButton.layer.cornerRadius = 5
        signUpButton.layer.masksToBounds = true
        signUpButton.enableButtonWithColor(false)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    private func startIndicatorAnimating() {
        signUpButton.setTitleColor(.clear, for: .normal)
        indicatorView.startAnimating()
    }
    
    private func stopIndicatorAnimating() {
        signUpButton.setTitleColor(.white, for: .normal)
        indicatorView.stopAnimating()
    }

}

extension UIButton {
    func enableButtonWithColor(_ isAllTextFieldsValid: Bool) {
        let alpha: CGFloat = isAllTextFieldsValid ? 1 : 0.5
        self.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 175/255, alpha: alpha)
        self.isEnabled = isAllTextFieldsValid
    }
}
