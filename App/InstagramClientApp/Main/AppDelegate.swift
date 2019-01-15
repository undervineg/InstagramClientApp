//
//  AppDelegate.swift
//  InstagramClientApp
//
//  Created by 심승민 on 31/12/2018.
//  Copyright © 2018 심승민. All rights reserved.
//

import UIKit
import InstagramEngine
import Firebase

//@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        let window = UIWindow(frame: UIScreen.main.bounds)
        let splashModule = SplashModule()
        splashModule.router.openLoginCallback = { mainVC in
            window.rootViewController = mainVC
        }
        splashModule.router.openMainCallback = { loginVC in
            window.rootViewController = loginVC
        }
        
        window.rootViewController = splashModule.viewController
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        
        self.window = window
        
        UITabBar.appearance().tintColor = .black
        
        return true
    }
}
