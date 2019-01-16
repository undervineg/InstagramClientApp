//
//  SharePhotoModule.swift
//  InstagramClientApp
//
//  Created by 심승민 on 16/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class SharePhotoModule {
    let viewController: SharePhotoViewController
    
    init(_ selectedImage: UIImage) {
        viewController = SharePhotoViewController(selectedImage)
    }
}
