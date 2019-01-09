//
//  RegisterRoute.swift
//  InstagramClientApp
//
//  Created by 심승민 on 09/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

protocol RegisterRoute {
    var registerTransition: Transition { get }
    
    func openRegisterPage()
}

extension RegisterRoute where Self: Routable {
    var registerTransition: Transition {
        return ModalTransition()
    }
    
    func openRegisterPage() {
        let factory = iOSViewControllerFactory()
        let router = RegisterRouter()
        let registerVC = factory.registerViewController(router: router)
        router.viewControllerBehind = registerVC
        self.open(registerVC, with: self.registerTransition)
    }
}
