//
//  MainModule.swift
//  InstagramClientApp
//
//  Created by 심승민 on 14/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class MainModule {
    let router: MainRouter
    let viewController: MainTabBarViewController
    
    init(router: MainRouter) {
        self.router = router
        
        let profileVC = UserProfileModule(router: router)
        viewController = MainTabBarViewController(subViewControllers: [profileVC.withNavigation])
        
        router.viewControllerBehind = viewController
        
        viewController.selectedIndex = 0
    }
}
