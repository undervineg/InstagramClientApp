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
    
    var loginTransition: Transition = ModalTransition()
    
    // LoginRoute
    
    func openLoginPage() {
        openLoginPage(with: loginTransition)
    }
    
    func openLoginPage(with transition: Transition) {
        let loginModule = LoginModule()
        loginModule.router.openTransition = transition
        
        open(loginModule.withNavigation, with: transition)
    }
    
    func openLoginPageAsRoot(_ callback: (UIViewController) -> Void) {
        let loginModule = LoginModule()
        loginModule.router.openTransition = loginTransition
        callback(loginModule.withNavigation)
    }

}
