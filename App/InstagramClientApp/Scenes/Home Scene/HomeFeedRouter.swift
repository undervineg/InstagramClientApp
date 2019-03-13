//
//  HomeFeedRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 22/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine

final class HomeFeedRouter: BasicRouter, HomeFeedRouter.Routes {
    typealias Routes = CameraRoute & CommentsRoute
    
    var cameraTransitionType: Transition = ModalTransition()
    
    var commentsTransition: Transition = PushTransition()
    
    // MARK: Camera Route
    
    func openCamera() {
        openCamera(with: cameraTransitionType)
    }
    
    func openCamera(with transition: Transition) {
        let cameraModule = CameraModule()
        cameraModule.router.openTransition = transition
        
        open(cameraModule.viewController, with: transition)
    }
    
    // MARK: Comment Route
    
    func openCommentsPage(postId: String) {
        openCommentsPage(postId: postId, with: commentsTransition)
    }
    
    func openCommentsPage(postId: String, with transition: Transition) {
        let module = CommentsModule(postId: postId)
        
        self.open(module.viewController, with: transition)
    }
}
