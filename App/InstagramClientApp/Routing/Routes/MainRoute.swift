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
        
        let mainTabBarVC = factory.mainViewController()

        return mainTabBarVC
    }
}
