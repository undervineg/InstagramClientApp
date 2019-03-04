//
//  UserSearchRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 20/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation
import InstagramEngine

final class UserSearchRouter: BasicRouter, UserSearchRouter.Routes {
    typealias Routes = UserProfileRoute
    
    var userProfileTransition: Transition = PushTransition()
    
    private let cache = NSCache<NSString, UserProfileModule>()
    
    func openUserProfilePage(of uid: String) {
        openUserProfilePage(of: uid, with: userProfileTransition)
    }
    
    func openUserProfilePage(of uid: String, with transition: Transition) {
        if let cachedModule = cache.object(forKey: uid as NSString) {
            open(cachedModule, uid, transition)
        } else {
            let module = UserProfileModule()
            open(module, uid, transition)
            cache.setObject(module, forKey: uid as NSString)
        }
    }
    
    // MARK: Private Methods
    private func open(_ module: UserProfileModule, _ uid: String, _ transition: Transition) {
        module.router.openTransition = transition
        module.viewController.uid = uid
        open(module.viewController, with: transition)
    }
}
