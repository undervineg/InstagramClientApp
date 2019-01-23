//
//  PhotoSelectorRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 16/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class PhotoSelectorRouter: BasicRouter, PhotoSelectorRouter.Routes {
    typealias Routes = SharePhotoRoute
    
    var sharePhotoTransition: Transition = PushTransition()
    
    func openSharePhotoPage(with selectedImage: UIImage) {
        let sharePhotoModule = SharePhotoModule(selectedImage)
        sharePhotoModule.router.openTransition = sharePhotoTransition
        
        open(sharePhotoModule.viewController, with: sharePhotoTransition)
    }
    
    func closePhotoSelectorPage() {
        self.close()
    }
}
