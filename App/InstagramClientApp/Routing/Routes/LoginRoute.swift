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
        let loginVC = prepareLoginScreen(nil)
        open(loginVC, with: loginTransition)
    }
    
    func openLoginPageAsRoot(with callback: @escaping (UIViewController) -> Void) {
        let loginVC = prepareLoginScreen(callback)
        callback(loginVC)
    }
    
    private func prepareLoginScreen(_ callback: ((UIViewController) -> Void)?) -> UIViewController {
        let factory = iOSViewControllerFactory()
        let router = LoginRouter()
        router.openMainCallback = callback
        let vc = factory.loginViewController(router: router)
        router.viewControllerBehind = vc
        return vc
    }
}
