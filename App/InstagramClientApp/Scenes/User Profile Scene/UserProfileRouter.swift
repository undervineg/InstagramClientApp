//
//  UserProfileRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 16/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class UserProfileRouter: BasicRouter, UserProfileRouter.Routes {
    typealias Routes = AuthRoute
    
    var authTransition: TransitionType = .modal
    
    
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
}
