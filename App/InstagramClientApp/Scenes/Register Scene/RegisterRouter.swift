//
//  RegisterRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 16/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class RegisterRouter: BasicRouter, RegisterRouter.Routes {
    typealias Routes = MainRoute & LoginRoute
    
    var openMainCallback: ((UIViewController) -> Void)? = nil
    
    var mainTransitionType: TransitionType = .modal
    var loginTransitionType: TransitionType = .push
    
    // MainRoute
    
    func openMainPage() {
        openMainPage(with: mainTransitionType)
    }
    
    func openMainPage(with transitionType: TransitionType) {
        guard let callback = openMainCallback else {
            let mainVC = viewControllerBehind?.presentingViewController as? MainTabBarViewController
            openTransition = mainTransitionType.object
            openTransition?.viewControllerBehind = mainVC
            mainVC?.setupChildViewControllers()
            self.close()
            return
        }
        openMainPageAsRoot(callback)
    }
    
    func openMainPageAsRoot(_ callback: (UIViewController) -> Void) {
        let mainModule = MainModule()
        let transition = mainTransitionType.object
        mainModule.router.openTransition = transition
        transition.viewControllerBehind = mainModule.viewController
        
        callback(mainModule.viewController)
    }
    
    // LoginRoute
    
    func openLoginPage() {
        if viewControllerBehind?.navigationController?.viewControllers.count ?? 0 > 1 {
            self.close()
        } else {
            openLoginPage(with: loginTransitionType)
        }
    }
    
    func openLoginPage(with transitionType: TransitionType) {
        let loginModule = LoginModule()
        let transition = transitionType.object
        loginModule.router.openTransition = transition
        loginModule.router.openMainCallback = openMainCallback
        
        open(loginModule.viewController, with: transition)
    }
    
    func openLoginPageAsRoot(_ callback: (UIViewController) -> Void) {
        //
    }

}
