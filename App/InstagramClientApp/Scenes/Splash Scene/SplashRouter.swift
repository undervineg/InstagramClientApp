//
//  SplashRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 10/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class SplashRouter: BasicRouter, SplashRouter.Routes {
    typealias Routes = MainRoute & LoginRoute
    
    var openMainCallback: ((UIViewController) -> Void)? = nil
    var openLoginCallback: ((UIViewController) -> Void)? = nil
    
    var mainTransition: Transition = ModalTransition()
    var loginTransition: Transition = ModalTransition()
    
    
    func openMainPage() {
        guard let openMainCallback = openMainCallback else { return }
        openMainPageAsRoot(openMainCallback)
    }
    
    func openMainPage(with transition: Transition) {
        //
    }
    
    func openMainPageAsRoot(_ callback: (UIViewController) -> Void) {
        let mainModule = MainModule()
        mainModule.router.openTransition = mainTransition
        callback(mainModule.viewController)
    }

    
    func openLoginPage() {
        guard let openLoginCallback = openLoginCallback else { return }
        openLoginPageAsRoot(openLoginCallback)
    }
    
    func openLoginPage(with transition: Transition) {
        //
    }
    
    func openLoginPageAsRoot(_ callback: (UIViewController) -> Void) {
        let loginModule = LoginModule()
        loginModule.router.openTransition = loginTransition
        loginModule.router.openMainCallback = openMainCallback
        callback(loginModule.withNavigation)
    }

}
