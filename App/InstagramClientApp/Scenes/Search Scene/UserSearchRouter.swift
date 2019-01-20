//
//  UserSearchRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 20/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import InstagramEngine

final class UserSearchRouter: BasicRouter, UserSearchRouter.Routes {
    typealias Routes = UserProfileRoute
    
    var userProfileTransition: TransitionType = .push
    
    func openUserProfilePage(of uid: String) {
        openUserProfilePage(of: uid, with: userProfileTransition)
    }
    
    func openUserProfilePage(of uid: String, with transition: TransitionType) {
        let userProfileModule = UserProfileModule()
        userProfileModule.router.openTransition = transition.object
        
        userProfileModule.viewController.uid = uid
        
        open(userProfileModule.viewController, with: transition.object)
    }
}
