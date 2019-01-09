//
//  StubAppDelegate.swift
//  InstagramClientAppTests
//
//  Created by 심승민 on 09/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import Firebase
@testable import InstagramClientApp

final class StubAppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        if let rootVC = window?.rootViewController as? RegisterUserViewController {
            rootVC.registerCallback?("", "", "", Data())
        }
        
        return true
    }
}
