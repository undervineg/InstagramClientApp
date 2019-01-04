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

        let gateway = FirebaseGateway(firebaseAuth: Auth.self, firebaseDatabase: Database.self)
        let useCase = RegisterUserUseCase(gateway: gateway, output: Presenter())
        let vc = RegisterUserViewController(registerCallback: useCase.register)
        
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
