//
//  MainRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 09/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class MainRouter: BasicRouter, MainRouter.Routes {
    typealias Routes = PhotoSelectorRoute
    
    var photoSelectorTransition: TransitionType = .modal
    var sharePhotoTransition: TransitionType = .push
    
    
    func openPhotoSelectorPage() {
        let photoModule = PhotoSelectorModule()
        let transition = photoSelectorTransition.object
        photoModule.router.openTransition = transition
        open(photoModule.withNavigation, with: transition)
    }
}
