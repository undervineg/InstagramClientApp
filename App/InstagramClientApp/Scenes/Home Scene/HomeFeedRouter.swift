//
//  HomeFeedRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 22/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

final class HomeFeedRouter: BasicRouter, HomeFeedRouter.Routes {
    typealias Routes = CameraRoute & CommentRoute
    
    // MARK: Camera Route
    var cameraTransitionType: Transition = ModalTransition()
    
    func openCamera() {
        openCamera(with: cameraTransitionType)
    }
    
    func openCamera(with transition: Transition) {
        let cameraModule = CameraModule()
        cameraModule.router.openTransition = transition
        
        open(cameraModule.viewController, with: transition)
    }
    
    // MARK: Comment Route
    var commentTransition: Transition = PushTransition()
    
    func openCommentPage() {
        openCommentPage(with: commentTransition)
    }
    
    func openCommentPage(with transition: Transition) {
        print(#function)
    }
}
