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
    
    var sharePhotoTransition: TransitionType = .push
    
    func openSharePhotoPage(with selectedImage: UIImage) {
        let sharePhotoModule = SharePhotoModule(selectedImage)
        let transition = sharePhotoTransition.object
        sharePhotoModule.router.openTransition = transition
        
        open(sharePhotoModule.viewController, with: transition)
    }
    
    func closePhotoSelectorPage() {
        self.close()
    }
}
