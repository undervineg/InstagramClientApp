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
    var commentsTransition: Transition = PushTransition()
    
    func openCommentsPage(currentPost: Post) {
        openCommentsPage(currentPost: currentPost, with: commentsTransition)
    }
    
    func openCommentsPage(currentPost: Post, with transition: Transition) {
        let module = CommentsModule(post: currentPost)
        
        self.open(module.viewController, with: transition)
    }
}