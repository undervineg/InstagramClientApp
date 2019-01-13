//
//  MainTabBarViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 09/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    
    convenience init(subViewControllers: [UIViewController]) {
        self.init()
        viewControllers = subViewControllers
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

}
