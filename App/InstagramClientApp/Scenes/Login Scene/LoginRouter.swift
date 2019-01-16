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
    
    var mainTransitionType: TransitionType = .modal
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
        let mainModule = MainModule()
        let transition = mainTransitionType.object
        mainModule.router.openTransition = transition
        transition.viewControllerBehind = mainModule.viewController
        
        callback(mainModule.viewController)
    }
    
    // RegisterRoute
    
    func openRegisterPage() {
        if viewControllerBehind?.navigationController?.viewControllers.count ?? 0 > 1 {
            self.close()
        } else {
            openRegisterPage(with: registerTransition)
        }
    }
    
    func openRegisterPage(with transitionType: TransitionType) {
        let registerModule = RegisterModule()
        let transition = transitionType.object
        registerModule.router.openTransition = transition
        registerModule.router.openMainCallback = openMainCallback
        
        open(registerModule.viewController, with: transition)
    }
    
    func openRegisterPageAsRoot(_ callback: (UIViewController) -> Void) {
        //
    }
}
