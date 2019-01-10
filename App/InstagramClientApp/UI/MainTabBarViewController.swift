//
//  MainTabBarViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 09/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    
    private var router: MainRouter.Routes?
    
    convenience init(router: MainRouter.Routes, subViewControllers: [UIViewController]) {
        self.init()
        viewControllers = subViewControllers
        self.router = router
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

}
