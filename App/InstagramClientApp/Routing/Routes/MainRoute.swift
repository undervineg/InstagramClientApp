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
    func prepareMainScreen() -> UIViewController
}

extension MainRoute where Self: Closable {
    func openMainPage() {
        // Close until current page(MainTabBarVC) appear
        self.close(to: self as? UIViewController)
    }
    
    func prepareMainScreen() -> UIViewController {
        let factory = iOSViewControllerFactory()
        let defaultVC = UIViewController()
        defaultVC.view.backgroundColor = .white
        let defaultNavigation = UINavigationController(rootViewController: defaultVC)

        let profileVC = factory.userProfileViewController()
        let profileNavigation = UINavigationController(rootViewController: profileVC)

        let router = MainRouter()
        let mainTabBarVC = MainTabBarViewController(subViewControllers: [defaultNavigation, profileNavigation],
                                                    router: router)
        router.viewControllerBehind = mainTabBarVC
        mainTabBarVC.selectedIndex = 0

        return mainTabBarVC
    }
}
