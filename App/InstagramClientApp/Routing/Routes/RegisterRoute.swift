//
//  RegisterRoute.swift
//  InstagramClientApp
//
//  Created by 심승민 on 09/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol RegisterRoute {
    var registerTransition: Transition { get }
    
    func openRegisterPage()
    func openRegisterPageWithTransition()
    func openRegisterPageAsRoot(with callback: @escaping (UIViewController) -> Void)
}

extension RegisterRoute where Self: Routable {
    var registerTransition: Transition {
        return ModalTransition()
    }
    
    func openRegisterPage() {
        openRegisterPageWithTransition()
    }
    
    func openRegisterPageWithTransition() {
        let registerVC = prepareRegisterScreen(nil)
        self.open(registerVC, with: self.registerTransition)
    }
    
    func openRegisterPageAsRoot(with callback: @escaping (UIViewController) -> Void) {
        let registerVC = prepareRegisterScreen(callback)
        callback(registerVC)
    }
    
    private func prepareRegisterScreen(_ callback: ((UIViewController) -> Void)?) -> UIViewController {
        let factory = iOSViewControllerFactory()
        let router = RegisterRouter()
        router.openMainCallback = callback
        let vc = factory.registerViewController(router: router)
        router.viewControllerBehind = vc
        return vc
    }
}
