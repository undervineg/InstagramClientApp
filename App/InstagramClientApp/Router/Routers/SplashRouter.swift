//
//  SplashRouter.swift
//  InstagramClientApp
//
//  Created by 심승민 on 10/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class SplashRouter: BasicRouter, SplashRouter.Route {
    typealias Route = MainRoute & RegisterRoute
    
    private(set) var window: UIWindow?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func openMainPage() {
        let mainVC = prepareMainScreen()
        window?.rootViewController = mainVC
    }
    
    func openRegisterPage() {
        let registerVC = prepareRegisterScreen()
        window?.rootViewController = registerVC
    }
    
    // MAKR: - Unused properties
    
    var registerTransition: Transition {
        return PushTransition()
    }
}
