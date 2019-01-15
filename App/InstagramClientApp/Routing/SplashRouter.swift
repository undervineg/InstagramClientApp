//
//  SplashRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 10/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class SplashRouter: BasicRouter, SplashRouter.Routes {
    typealias Routes = AuthRoute & MainRoute
    
    var openMainCallback: ((UIViewController) -> Void)? = nil
    var openLoginCallback: ((UIViewController) -> Void)? = nil
    
    var mainTransitionType: TransitionType = .modal
    var authTransition: TransitionType = .modal
    
    // MainRoute
    
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
        transition.viewControllerBehind = mainModule.viewController
        callback(mainModule.viewController)
    }

    
    // AuthRoute
    
    func openAuthPage(_ root: AuthModule.RootType) {
        guard let openLoginCallback = openLoginCallback else { return }
        openAuthPageAsRoot(root, openLoginCallback)
    }
    
    func openAuthPage(_ root: AuthModule.RootType, with transitionType: TransitionType) {
        //
    }
    
    func openAuthPageAsRoot(_ root: AuthModule.RootType, _ callback: (UIViewController) -> Void) {
        let authModule = AuthModule(rootType: root)
        let transition = authTransition.object
        authModule.router.openMainCallback = self.openMainCallback
        authModule.router.openTransition = transition
        transition.viewControllerBehind = authModule.viewController
        callback(authModule.viewController)
    }
}
