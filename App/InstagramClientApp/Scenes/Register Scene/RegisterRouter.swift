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
    
    var mainTransition: Transition = ModalTransition()
    var loginTransition: Transition = PushTransition()
    
    // MainRoute
    
    func openMainPage() {
        openMainPage(with: mainTransition)
    }
    
    func openMainPage(with transition: Transition) {
        guard let callback = openMainCallback else {
            let mainVC = viewController?.presentingViewController as? MainTabBarViewController
            openTransition = mainTransition
            openTransition?.viewController = mainVC
            mainVC?.setupChildViewControllers()
            self.close()
            return
        }
        openMainPageAsRoot(callback)
    }
    
    func openMainPageAsRoot(_ callback: (UIViewController) -> Void) {
        let mainModule = MainModule()
        mainModule.router.openTransition = mainTransition
        mainTransition.viewController = mainModule.viewController
        
        callback(mainModule.viewController)
    }
    
    // LoginRoute
    
    func openLoginPage() {
        if viewController?.navigationController?.viewControllers.count ?? 0 > 1 {
            self.close()
        } else {
            openLoginPage(with: loginTransition)
        }
    }
    
    func openLoginPage(with transition: Transition) {
        let loginModule = LoginModule()
        loginModule.router.openTransition = transition
        loginModule.router.openMainCallback = openMainCallback
        
        open(loginModule.viewController, with: transition)
    }
    
    func openLoginPageAsRoot(_ callback: (UIViewController) -> Void) {
        //
    }

}
