//
//  LoginModule.swift
//  InstagramClientApp
//
//  Created by 심승민 on 13/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import FirebaseAuth
import InstagramEngine

final class LoginModule {
    let router: LoginRouter
    let viewController: LoginViewController
    private let service: LoginService
    private let presenter: LoginPresenter
    private let useCase: LoginUseCase
    
    var withNavigation: UINavigationController {
        let navigationVC = UINavigationController(rootViewController: viewController)
        return navigationVC
    }
    
    init(router: LoginRouter, _ openMainCallback: ((UIViewController) -> Void)? = nil) {
        self.router = router
        viewController = LoginViewController(router: router)
        service = LoginService(auth: Auth.self)
        presenter = LoginPresenter(view: viewController)
        useCase = LoginUseCase(client: service, output: presenter)
        
        router.openMainCallback = openMainCallback
        router.viewControllerBehind = viewController
        
        viewController.login = useCase.login
    }
}
