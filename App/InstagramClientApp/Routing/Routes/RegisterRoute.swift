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
        return PushTransition()
    }
    
    func openRegisterPage() {
        openRegisterPageWithTransition()
    }
    
    func openRegisterPageWithTransition() {
        let router = RegisterRouter()
        let registerModule = RegisterModule(router: router)
        
        let registerPage = (viewControllerBehind?.navigationController != nil) ?
            registerModule.viewController : registerModule.withNavigation

        router.openTransition = (viewControllerBehind?.navigationController != nil) ?
            registerTransition : ModalTransition()
        
        open(registerPage, with: router.openTransition!)
    }
    
    func openRegisterPageAsRoot(with openMainCallback: @escaping (UIViewController) -> Void) {
        let router = RegisterRouter()
        let registerModule = RegisterModule(router: router)
        router.openMainCallback = openMainCallback
        openMainCallback(registerModule.viewController)
    }
}
