//
//  AuthModule.swift
//  InstagramClientApp
//
//  Created by 심승민 on 14/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class AuthModule {
    let router: AuthRouter
    let viewController: UINavigationController
    private let loginModule: LoginModule
    private let registerModule: RegisterModule
    
    enum RootType {
        case login
        case register
    }
    
    init(rootType: RootType, _ openMainCallback: ((UIViewController) -> Void)? = nil) {
        router = AuthRouter()
        
        loginModule = LoginModule(router: router)
        registerModule = RegisterModule(router: router)
        
        let rootVC = (rootType == .login) ? loginModule.viewController : registerModule.viewController
        viewController = UINavigationController(rootViewController: rootVC)
        
        router.viewControllerBehind = viewController
    }
}
