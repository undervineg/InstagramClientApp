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
    
    var photoSelectorTransition: Transition = ModalTransition()
    var sharePhotoTransition: Transition = PushTransition()
    
    
    func openPhotoSelectorPage() {
        let photoModule = PhotoSelectorModule()
        photoModule.router.openTransition = photoSelectorTransition
        open(photoModule.withNavigation, with: photoSelectorTransition)
    }
}
