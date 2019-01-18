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
    
    var mainTransitionType: TransitionType = .modal
    var loginTransitionType: TransitionType = .modal
    
    
    func openMainPage() {
        guard let openMainCallback = openMainCallback else { return }
        openMainPageAsRoot(openMainCallback)
    }
    
    func openMainPage(with transitionType: TransitionType) {
        //
    }
    
    func openMainPageAsRoot(_ callback: (UIViewController) -> Void) {
        let mainModule = MainModule()
        let transition = mainTransitionType.object
        mainModule.router.openTransition = transition
        callback(mainModule.viewController)
    }

    
    func openLoginPage() {
        guard let openLoginCallback = openLoginCallback else { return }
        openLoginPageAsRoot(openLoginCallback)
    }
    
    func openLoginPage(with transitionType: TransitionType) {
        //
    }
    
    func openLoginPageAsRoot(_ callback: (UIViewController) -> Void) {
        let loginModule = LoginModule()
        let transition = loginTransitionType.object
        loginModule.router.openTransition = transition
        loginModule.router.openMainCallback = openMainCallback
        callback(loginModule.withNavigation)
    }

}
