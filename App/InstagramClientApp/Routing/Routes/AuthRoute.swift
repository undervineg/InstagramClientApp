//
//  AuthRoute.swift
//  InstagramClientApp
//
//  Created by 심승민 on 14/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol AuthRoute {
    var authTransition: Transition { get }
    
    func openAuthPage(_ root: AuthModule.RootType)
    func openAuthPage(_ root: AuthModule.RootType, with transition: Transition)
    func openAuthPageAsWindowRoot(_ root: AuthModule.RootType, with openMainCallback: @escaping (UIViewController) -> Void)
}

extension AuthRoute where Self: Routable & Closable {
    var authTransition: Transition {
        return ModalTransition()
    }
    
    func openAuthPage(_ root: AuthModule.RootType) {
        openAuthPage(root, with: authTransition)
    }
    
    func openAuthPage(_ root: AuthModule.RootType, with transition: Transition) {
        let authModule = AuthModule(rootType: root)
        authModule.router.openTransition = transition
        open(authModule.viewController, with: transition)
    }
    
    func openAuthPageAsWindowRoot(_ root: AuthModule.RootType, with openMainCallback: @escaping (UIViewController) -> Void) {
        let authModule = AuthModule(rootType: root, openMainCallback)
        let transition = authTransition
        authModule.router.openTransition = transition
        transition.viewControllerBehind = authModule.viewController
        openMainCallback(authModule.viewController)
    }
}

protocol LoginRoute {
    var loginTransition: Transition { get }
    
    func openLoginPage()
}

extension LoginRoute where Self: Routable {
    var loginTransition: Transition {
        return PushTransition()
    }
    
    func openLoginPage() {
        guard let router = self as? AuthRouter else { return }
        
        if let navigation = self.viewControllerBehind, navigation.children.first is RegisterUserViewController {
            let transition = loginTransition
            let loginModule = LoginModule(router: router)
            router.viewControllerBehind = navigation
            router.openTransition = transition
            
            open(loginModule.viewController, with: transition)
        } else {
            router.close()
        }
    }
}

protocol RegisterRoute {
    var registerTransition: Transition { get }
    
    func openRegisterPage()
}

extension RegisterRoute where Self: Routable {
    var registerTransition: Transition {
        return PushTransition()
    }
    
    func openRegisterPage() {
        guard let router = self as? AuthRouter else { return }
        
        if let navigation = self.viewControllerBehind, navigation.children.first is LoginViewController {
            let transition = registerTransition
            let registerModule = RegisterModule(router: router)
            router.viewControllerBehind = navigation
            router.openTransition = transition
            
            open(registerModule.viewController, with: transition)
        } else {
            router.close()
        }
    }
}
