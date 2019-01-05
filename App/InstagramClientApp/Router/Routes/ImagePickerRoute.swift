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
    
    func openImagePicker(_ imagePicker: UIImagePickerController, with transition: Transition?)
}

extension ImagePickerRoute where Self: Routable {
    var imagePickerTransition: Transition {
        return ModalTransition()
    }
    
    func openImagePicker(_ imagePicker: UIImagePickerController, with transition: Transition? = nil) {
        let transition = transition ?? self.imagePickerTransition
        self.open(imagePicker, with: transition)
    }
}
