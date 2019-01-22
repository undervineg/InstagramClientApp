//
//  HomeFeedRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 22/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

final class HomeFeedRouter: BasicRouter, HomeFeedRouter.Routes {
    typealias Routes = CameraRoute
    
    var cameraTransitionType: TransitionType = .modal
    
    func openCamera() {
        openCamera(with: cameraTransitionType)
    }
    
    func openCamera(with transitionType: TransitionType) {
        let cameraModule = CameraModule()
        let transition = transitionType.object
        cameraModule.router.openTransition = transition
        
        open(cameraModule.viewController, with: transition)
    }
}
