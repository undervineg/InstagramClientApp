//
//  ImagePickerRoute.swift
//  InstagramClientApp
//
//  Created by 심승민 on 04/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol ImagePickerRoute {
    var imagePickerTransition: Transition { get }
    
    func openImagePicker(with transition: Transition?)
}

extension ImagePickerRoute where Self: Routable {
    var imagePickerTransition: Transition {
        return ModalTransition()
    }
    
    func openImagePicker(with transition: Transition? = nil) {
        guard
            let presentingViewController
            = self.viewControllerBehind as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate)
            else { return }
        
        let transition = transition ?? self.imagePickerTransition
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = presentingViewController
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        self.open(imagePicker, with: transition)
    }
}
