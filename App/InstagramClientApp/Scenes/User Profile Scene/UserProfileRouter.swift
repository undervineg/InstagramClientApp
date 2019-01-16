//
//  UserProfileRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 16/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class UserProfileRouter: BasicRouter, UserProfileRouter.Routes {
    typealias Routes = LoginRoute
    
    var loginTransitionType: TransitionType = .modal
    
    // LoginRoute
    
    func openLoginPage() {
        openLoginPage(with: loginTransitionType)
    }
    
    func openLoginPage(with transitionType: TransitionType) {
        let loginModule = LoginModule()
        let transition = transitionType.object
        loginModule.router.openTransition = transition
        
        open(loginModule.withNavigation, with: transition)
    }
    
    func openLoginPageAsRoot(_ callback: (UIViewController) -> Void) {
        let loginModule = LoginModule()
        let transition = loginTransitionType.object
        loginModule.router.openTransition = transition
        callback(loginModule.withNavigation)
    }

}
