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
    
    private var router: RegisterRouter.Routes?
    
    var registerCallback: ((String, String, String, Data, @escaping (RegisterUserUseCase.Error?) -> Void) -> ())?
    
    convenience init(router: RegisterRouter.Routes) {
        self.init()
        self.router = router
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileImageButton.layer.cornerRadius = profileImageButton.frame.width/2
        profileImageButton.layer.masksToBounds = true
        
        signUpButton.isEnabled = false
        signUpButton.backgroundColor = UIColor(red: 123/255, green: 115/255, blue: 231/255, alpha: 0.5)
        
        profileImageButton.addTarget(self, action: #selector(openImagePicker(_:)), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUp(_:)), for: .touchUpInside)
        emailTextField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
    }
    
    @objc private func openImagePicker(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true

        router?.openImagePicker(imagePicker, with: nil)
    }
    
    @objc private func handleTextInputChange(_ sender: UITextField) {
        signUpButton.backgroundColor = isAllTextFieldsValid() ? UIColor(red: 123/255, green: 115/255, blue: 231/255, alpha: 1) : UIColor(red: 123/255, green: 115/255, blue: 231/255, alpha: 0.5)
        signUpButton.isEnabled = isAllTextFieldsValid() ? true : false
    }
    
    @objc private func signUp(_ sender: UIButton) {
        guard isAllTextFieldsValid() else { return }
        
        let email = emailTextField.text ?? ""
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let profileImageData = profileImageButton.imageView?.image?.jpegData(compressionQuality: 0.3)
        
        registerCallback?(email, username, password, profileImageData!) {
            print($0)
        }
    }
    
    private func isAllTextFieldsValid() -> Bool {
        let isEmailValid = emailTextField.text?.count ?? 0 > 0
        let isUsernameValid = usernameTextField.text?.count ?? 0 > 0
        let isPasswordValid = passwordTextField.text?.count ?? 0 > 0
        
        return (isEmailValid && isUsernameValid && isPasswordValid)
    }
}

extension RegisterUserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let editedImage = info[.editedImage] as? UIImage
        profileImageButton.setImage(editedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        router?.closeImagePicker(picker)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        router?.closeImagePicker(picker)
    }
}

extension RegisterUserViewController: RegisterUserView {
    func displayMain() {
        // TODO: Open Main
    }
    
    func display(_ errorMessage: String) {
        let alert = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
