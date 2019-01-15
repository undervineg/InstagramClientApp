//
//  MainTabBarViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 09/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class MainTabBarViewController: UITabBarController, UITabBarControllerDelegate {

    convenience init(subViewControllers: [UIViewController]) {
        self.init()
        viewControllers = subViewControllers
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        tabBar.tintColor = .black
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewControllers?.firstIndex(of: viewController) == 2 {
            return false
        }
        return true
    }
}
