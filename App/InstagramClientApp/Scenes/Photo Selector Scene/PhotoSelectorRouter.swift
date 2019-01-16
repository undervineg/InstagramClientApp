//
//  PhotoSelectorRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 16/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

final class PhotoSelectorRouter: BasicRouter, PhotoSelectorRouter.Routes {
    typealias Routes = SharePhotoRoute
    
    var sharePhotoTransition: TransitionType = .push
    
    func openSharePhotoPage() {
        let sharePhotoModule = SharePhotoModule()
        let transition = sharePhotoTransition.object
        open(sharePhotoModule.viewController, with: transition)
    }
    
    func closePhotoSelectorPage() {
        self.close()
    }
}
