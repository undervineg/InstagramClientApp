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
    
    init(router: MainRouter, _ openMainCallback: ((UIViewController) -> Void)? = nil) {
        self.router = router
        
        let homeVC = HomeModule().withNavigation
        let searchVC = SearchModule().withNavigation
        let plusVC = UIViewController()
        let likeVC = UIViewController()
        let profileVC = UserProfileModule(router: router).withNavigation
        
        homeVC.configureTabBarItem(image: "home_unselected", selectedImage: "home_selected")
        searchVC.configureTabBarItem(image: "search_unselected", selectedImage: "search_selected")
        plusVC.configureTabBarItem(image: "plus_unselected", selectedImage: "plus_unselected")
        likeVC.configureTabBarItem(image: "like_unselected", selectedImage: "like_selected")
        profileVC.configureTabBarItem(image: "profile_unselected", selectedImage: "profile_selected")
        
        let childVCs = [homeVC, searchVC, plusVC, likeVC, profileVC]
        viewController = MainTabBarViewController(subViewControllers: childVCs)
        viewController.updateInsets()
        router.viewControllerBehind = viewController
        viewController.selectedIndex = 0
    }
}

extension UIViewController {
    func configureTabBarItem(image: String, selectedImage: String) {
        tabBarItem = UITabBarItem(title: nil,
                                  image: UIImage(named: image)?.withRenderingMode(.alwaysTemplate),
                                  selectedImage: UIImage(named: selectedImage)?.withRenderingMode(.alwaysTemplate))
    }
}

extension UITabBarController {
    func updateInsets() {
        tabBar.items?.forEach {
            $0.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
    }
}
