//
//  AuthRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 14/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class AuthRouter: BasicRouter, AuthRouter.Routes {
    typealias Routes = MainRoute & LoginRoute & RegisterRoute
    
    var openMainCallback: ((UIViewController) -> Void)? = nil
    
    var mainTransitionType: TransitionType = .modal
    var loginTransition: TransitionType = .push
    var registerTransition: TransitionType = .push
    
    // MainRoute
    
    func openMainPage() {
        openMainPage(with: mainTransitionType)
    }
    
    func openMainPage(with transitionType: TransitionType) {
        guard let callback = openMainCallback else {
            openTransition = mainTransitionType.object
            openTransition?.viewControllerBehind = viewControllerBehind?.presentingViewController
            self.close()
            return
        }
        openMainPageAsRoot(callback)
    }
    
    func openMainPageAsRoot(_ callback: (UIViewController) -> Void) {
        let router = MainRouter()
        let mainModule = MainModule(router: router)
        let transition = mainTransitionType.object
        router.openTransition = transition
        transition.viewControllerBehind = mainModule.viewController
        
        callback(mainModule.viewController)
    }
    
    // LoginRoute
    
    func openLoginPage() {
        if let navigation = self.viewControllerBehind, navigation.children.first is RegisterUserViewController {
            let transition = loginTransition.object
            let loginModule = LoginModule(router: self)
            self.viewControllerBehind = navigation
            self.openTransition = transition

            open(loginModule.viewController, with: transition)
        } else {
            self.close()
        }
    }
    
    // RegisterRoute
    
    func openRegisterPage() {
        if let navigation = self.viewControllerBehind, navigation.children.first is LoginViewController {
            let transition = registerTransition.object
            let registerModule = RegisterModule(router: self)
            self.viewControllerBehind = navigation
            self.openTransition = transition

            open(registerModule.viewController, with: transition)
        } else {
            self.close()
        }
    }
}
