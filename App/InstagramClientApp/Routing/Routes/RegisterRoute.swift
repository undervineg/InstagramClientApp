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
    func prepareRegisterScreen() -> UIViewController
}

extension RegisterRoute where Self: Routable {
    var registerTransition: Transition {
        return ModalTransition()
    }
    
    func openRegisterPage() {
        let registerVC = prepareRegisterScreen()
        self.open(registerVC, with: self.registerTransition)
    }
    
    func prepareRegisterScreen() -> UIViewController {
        let factory = iOSViewControllerFactory()
        let router = RegisterRouter()
        let vc = factory.registerViewController(router: router)
        router.viewControllerBehind = vc
        return vc
    }
}
