//
//  MainRoute.swift
//  InstagramClientApp
//
//  Created by 심승민 on 09/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol MainRoute {
    var mainTransition: Transition { get }
    
    func openMainPage()
    func openMainPage(with transition: Transition)
    func openMainPageAsWindowRoot(with openLoginCallback: @escaping (UIViewController) -> Void)
}

extension MainRoute where Self: Routable & Closable {
    var mainTransition: Transition {
        return ModalTransition()
    }
    
    func openMainPage() {
        openMainPage(with: mainTransition)
    }
    
    func openMainPage(with transition: Transition) {
        self.close()
    }
    
    func openMainPageAsWindowRoot(with openLoginCallback: @escaping (UIViewController) -> Void) {
        let router = MainRouter()
        let mainModule = MainModule(router: router)
        let transition = mainTransition
        router.openTransition = transition
        transition.viewControllerBehind = mainModule.viewController
        openLoginCallback(mainModule.viewController)
    }
}
