//
//  MainRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 09/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class MainRouter: BasicRouter, MainRouter.Routes {
    typealias Routes = AuthRoute & PhotoSelectorRoute
    
    var authTransition: TransitionType = .modal
    var photoSelectorTransition: TransitionType = .modal
    
    // AuthRoute
    
    func openAuthPage(_ root: AuthModule.RootType) {
        openAuthPage(root, with: authTransition)
    }
    
    func openAuthPage(_ root: AuthModule.RootType, with transitionType: TransitionType) {
        let authModule = AuthModule(rootType: root)
        let transition = transitionType.object
        authModule.router.openTransition = transition
        open(authModule.viewController, with: transition)
    }
    
    func openAuthPageAsRoot(_ root: AuthModule.RootType, _ callback: (UIViewController) -> Void) {
        let authModule = AuthModule(rootType: root)
        let transition = authTransition.object
        authModule.router.openTransition = transition
        callback(authModule.viewController)
    }
    
    func openPhotoSelectorPage() {
        let photoModule = PhotoSelectorModule(router: self)
        let transition = photoSelectorTransition.object
        photoModule.router.openTransition = transition
        open(photoModule.withNavigation, with: transition)
    }
    
    func closePhotoSelectorPage() {
        close()
    }
}
