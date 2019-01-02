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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        let vc = RegisterUserViewController()
        let gateway = FirebaseGateway(firebase: Auth.self)
        let useCase = RegisterUserUseCase(gateway: gateway, output: Presenter())
        vc.register = useCase.register
        
        window?.rootViewController = vc
        
        return true
    }

}

private class Presenter: RegisterUserUseCaseOutput {
    func registerSucceeded(_ user: UserEntity) {
        
    }
    
    func registerFailed(_ error: RegisterUserUseCase.Error) {
        
    }
}
