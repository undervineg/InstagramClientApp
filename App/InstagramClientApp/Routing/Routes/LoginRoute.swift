//
//  LoginRoute.swift
//  InstagramClientApp
//
//  Created by 심승민 on 04/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol LoginRoute {
    var loginTransition: Transition { get }
    
    func openLoginPage()
    func openLoginPageWithTransition()
    func openLoginPageAsRoot(with callback: @escaping (UIViewController) -> Void)
}

extension LoginRoute where Self: Routable {
    var loginTransition: Transition {
        return PushTransition()
    }
    
    func openLoginPage() {
        openLoginPageWithTransition()
    }
    
    func openLoginPageWithTransition() {
        let router = LoginRouter()
        let loginModule = LoginModule(router: router, nil)
        
        let loginPage = (viewControllerBehind?.navigationController != nil) ?
            loginModule.viewController : loginModule.withNavigation
        router.openTransition = (viewControllerBehind?.navigationController != nil) ?
            loginTransition : ModalTransition()
        
        open(loginPage, with: router.openTransition!)
    }
    
    func openLoginPageAsRoot(with callback: @escaping (UIViewController) -> Void) {
        let router = LoginRouter()
        router.openMainCallback = callback
        let loginModule = LoginModule(router: router, callback)
        callback(loginModule.withNavigation)
    }
}
