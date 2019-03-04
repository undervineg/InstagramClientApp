//
//  LoginRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 16/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class LoginRouter: BasicRouter, LoginRouter.Routes {
    typealias Routes = MainRoute & RegisterRoute
    
    var openMainCallback: ((UIViewController) -> Void)? = nil
    
    var mainTransition: Transition = ModalTransition()
    var registerTransition: Transition = PushTransition()
    
    // MainRoute
    
    func openMainPage() {
        openMainPage(with: mainTransition)
    }
    
    func openMainPage(with transition: Transition) {
        guard let callback = openMainCallback else {
            let mainVC = viewController?.presentingViewController as? MainTabBarViewController
            openTransition = transition
            openTransition?.viewController = mainVC
            mainVC?.setupChildViewControllers()
            self.close()
            return
        }
        openMainPageAsRoot(callback)
    }
    
    func openMainPageAsRoot(_ callback: (UIViewController) -> Void) {
        let mainModule = MainModule()
        let transition = mainTransition
        mainModule.router.openTransition = transition
        transition.viewController = mainModule.viewController
        
        callback(mainModule.viewController)
    }
    
    // RegisterRoute
    
    func openRegisterPage() {
        if viewController?.navigationController?.viewControllers.count ?? 0 > 1 {
            self.close()
        } else {
            openRegisterPage(with: registerTransition)
        }
    }
    
    func openRegisterPage(with transition: Transition) {
        let registerModule = RegisterModule()
        registerModule.router.openTransition = transition
        registerModule.router.openMainCallback = openMainCallback
        
        open(registerModule.viewController, with: transition)
    }
    
    func openRegisterPageAsRoot(_ callback: (UIViewController) -> Void) {
        //
    }
}
