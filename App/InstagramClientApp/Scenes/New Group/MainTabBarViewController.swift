//
//  MainTabBarViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 09/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class MainTabBarViewController: UITabBarController {

    // MARK: Router
    private var router: MainRouter.Routes?
    
    // MARK: Initializer
    convenience init(router: MainRouter.Routes) {
        self.init()
        self.router = router
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        tabBar.tintColor = .black
    }
}

extension MainTabBarViewController: UITabBarControllerDelegate {
    
    // MARK: Tab Bar Contoller Delegate
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewControllers?.firstIndex(of: viewController) == 2 {
            router?.openPhotoSelectorPage()
            return false
        }
        return true
    }
}
