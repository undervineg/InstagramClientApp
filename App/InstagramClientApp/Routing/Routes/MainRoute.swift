//
//  MainRoute.swift
//  InstagramClientApp
//
//  Created by 심승민 on 09/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol MainRoute {
    func openMainPage()
    func openMainPageWithTransition()
    func openMainPageAsRoot(with callback: @escaping (UIViewController) -> Void)
}

extension MainRoute where Self: Closable {
    func openMainPage() {
        openMainPageWithTransition()
    }
    
    func openMainPageWithTransition() {
        // Close until current page(MainTabBarVC) appear
        self.close(to: self as? UIViewController)
    }
    
    func openMainPageAsRoot(with callback: @escaping (UIViewController) -> Void) {
        let mainVC = prepareMainScreen(callback)
        callback(mainVC)
    }
    
    private func prepareMainScreen(_ callback: @escaping (UIViewController) -> Void) -> UIViewController {
        let factory = iOSViewControllerFactory()
        let router = MainRouter()
        router.openLoginCallback = callback
        let mainTabBarVC = factory.mainViewController(router: router)
        router.viewControllerBehind = mainTabBarVC
        return mainTabBarVC
    }
}
