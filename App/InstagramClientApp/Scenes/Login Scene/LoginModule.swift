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
        return UINavigationController(rootViewController: viewController)
    }
    
    init() {
        self.router = LoginRouter()
        viewController = LoginViewController(router: router)
        service = LoginService(auth: Auth.self)
        presenter = LoginPresenter(view: viewController)
        useCase = LoginUseCase(client: service, output: presenter)
        
        router.viewControllerBehind = viewController
        
        viewController.login = useCase.login
    }
}
