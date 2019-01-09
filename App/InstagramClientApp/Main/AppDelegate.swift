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
        let factory = iOSViewControllerFactory()
        let router = SplashRouter(window: window)
        let splashVC = factory.splashViewController(router: router)
        
        window.rootViewController = splashVC
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        
        self.window = window
        
        return true
    }
}
